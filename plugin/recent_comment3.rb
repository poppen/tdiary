# $Revision: 1.31 $
# recent_comment3: 最近のツッコミをリストアップする
#
#   @secure = true な環境では動作しません．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'
require 'time'

def recent_comment3_format(format, *args)
	format.gsub(/\$(\d)/) {|s| args[$1.to_i - 1]}
end

def recent_comment3_init
   @conf['recent_comment3.cache'] ||= "#{@cache_path}/recent_comments"
   @conf['recent_comment3.cache_size'] ||= 50
   @conf['recent_comment3.max'] ||= 3
   @conf['recent_comment3.date_format'] ||= "(%m-%d)"
   @conf['recent_comment3.except_list'] ||= ''
	@conf['recent_comment3.format'] ||= '<a href="$2" title="$3">$4 $5</a>'
   @conf['recent_comment3.tree'] ||= ""
   @conf['recent_comment3.titlelen'] ||= 20
end

def recent_comment3(ob_max = 'OBSOLUTE' ,sep = 'OBSOLUTE',ob_date_format = 'OBSOLUTE',*ob_except )
	return 'DO NOT USE IN SECURE MODE' if @conf.secure

   recent_comment3_init
   
   cache = @conf['recent_comment3.cache'].untaint
   max = @conf['recent_comment3.max']
   date_format = @conf['recent_comment3.date_format'] 
   except = @conf['recent_comment3.except_list'].split(/,/)
	format = @conf['recent_comment3.format']
   titlelen = @conf['recent_comment3.titlelen']

   entries = {}
   tree_order =[]
   order = []
   idx = 0
   PStore.new(cache).transaction do |db|
      break unless db.root?('comments')
      db['comments'].each do |c|
         break if idx >= max or c.nil?
         comment, date, serial = c
         next unless comment.visible?
         next if except.include?(comment.name)
         a = @index + anchor("#{date.strftime('%Y%m%d')}#c#{'%02d' % serial}")
         popup = CGI::escapeHTML(comment.shorten( @conf.comment_length ))
         str = CGI::escapeHTML(comment.name)
         date_str = comment.date.strftime(date_format)

         idx += 1

         entry_date = "#{date.strftime('%Y%m%d')}"
         comment_str = entries[entry_date]

         if comment_str == nil then
            comment_str = []
            tree_order << entry_date
         end

         comment_str << recent_comment3_format(format, idx, a, popup, str, date_str)
         entries[entry_date] = comment_str
         order << entry_date

      end
		db.abort
   end

   result = []
   
   if @conf['recent_comment3.tree'] == "t" then
      if entries.size == 0
         ''
      else
         cgi = CGI::new
         def cgi.referer; nil; end
            
         tree_order.each { | entry_date |
            a_entry = @index + anchor(entry_date)
            cgi.params['date'] = [entry_date]
            diary = TDiaryDay::new(cgi, '', @conf)
            
            if diary != nil then
               title = diary.diaries[entry_date].title.gsub( /<[^>]*>/, '' )
            end
            if title == nil || title.length == 0 || title.strip.delete('　').delete(' ').length == 0 then
               date = Time.parse(entry_date)
               title = "#{date.strftime @date_format}"
            end
            
            result << "<li>"
            result << %Q|<a href="#{a_entry}">#{@conf.shorten( title, 20 )}</a><br>|
            entries[entry_date].sort.each { | comment_str |
               result << comment_str + "<br>"
            }
            result << "</li>\n"
         }
         
         %Q|<ul class="recent-comment">\n| + result.join( '' ) + "</ul>\n"
      end
   else
      if entries.size == 0
         ''
      else
         order.each do | entry_date |
            result << "<li>#{entries[entry_date][0]}</li>\n"
            entries[entry_date].shift
         end
         %Q|<ol class="recent-comment">\n| + result.join( '' ) + "</ol>\n"
      end
   end
end

add_update_proc do
   recent_comment3_init
   
   date = @date.strftime( '%Y%m%d' )
   cache = @conf['recent_comment3.cache'].untaint
   size = @conf['recent_comment3.cache_size']
   
   if @mode == 'comment' and @comment and @comment.visible? then
      PStore.new( cache ).transaction do |db|
         comment = @comment
         serial = 0
         @diaries[date].each_comment do
            serial += 1
         end
         db['comments'] = Array.new( size ) unless db.root?( 'comments' )
         if db['comments'][0].nil? or comment != db['comments'][0][0]
            db['comments'].unshift([comment, @date, serial]).pop
         end
      end
   elsif @mode == 'showcomment'
      PStore.new( cache ).transaction do |db|
         break unless db.root?('comments')
         
         @diaries[date].each_comment do |dcomment|
            db['comments'].each do |c|
               break if c.nil?
               comment, cdate, serial = c
               next if cdate.strftime('%Y%m%d') != date
               if comment == dcomment and comment.date == dcomment.date
                  comment.show = dcomment.visible?
                  next
               end
            end
         end
      end
   end
end

if @mode == 'saveconf'
   def saveconf_recent_comment3
      @conf['recent_comment3.max'] = @cgi.params['recent_comment3.max'][0].to_i
      @conf['recent_comment3.date_format'] = @cgi.params['recent_comment3.date_format'][0]
      @conf['recent_comment3.except_list'] = @cgi.params['recent_comment3.except_list'][0]
      @conf['recent_comment3.format'] = @cgi.params['recent_comment3.format'][0]
      @conf['recent_comment3.tree'] = @cgi.params['recent_comment3.tree'][0]
      @conf['recent_comment3.titlelen'] = @cgi.params['recent_comment3.titlelen'][0].to_i
   end
end

# vim: ts=3
