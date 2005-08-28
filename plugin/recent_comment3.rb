# $Revision: 1.21 $
# recent_comment3: 最近のツッコミをリストアップする
#
#   @secure = true な環境では動作しません．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'
require 'date'

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
	return '' if @conf.secure

   recent_comment3_init
   
   cache = @conf['recent_comment3.cache']
   max = @conf['recent_comment3.max']
   date_format = @conf['recent_comment3.date_format'] 
   except = @conf['recent_comment3.except_list'].split(/,/)
	format = @conf['recent_comment3.format']
   titlelen = @conf['recent_comment3.titlelen']

   entries = {}
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
         if comment_str == nill then
            comment_str = []
            order << entry_date
         end
         comment_str << recent_comment3_format(format, idx, a, popup, str, date_str)
         entries[entry_date] = comment_str

      end
		db.abort
   end

   if @conf['recent_comment3.tree'] == "t" then
      if entries.size == 0
         ''
      else
         cgi = CGI::new
         def cgi.referer; nil; end
            
         result = []
         order.each { | entry_date |
            a_entry = @index + anchor(entry_date)
            cgi.params['date'] = [entry_date]
            diary = TDiaryDay::new(cgi, '', @conf)
            
            if diary != nill then
               title = diary.diaries[entry_date].title.gsub( /<[^>]*>/, '' )
            end
            if title == nill || title.length == 0 || title.strip.delete('　').delete(' ').length == 0 then
               title = "#{entry_date}"
            end
            
            result << "<li>"
            result << %Q|<a href="#{anchor(a_entry)}">#{@conf.shorten( title, 20 )}</a><br>|
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
         result = []
         order.each do | entry_date |
            entries[entry_date].each do | comment_str |
               result << "<li>#{comment_str}</li>\n"
            end
         end
         %Q|<ol class="recent-comment">\n| + result.join( '' ) + "</ol>\n"
      end
   end
end

add_update_proc do
   recent_comment3_init
   
   date = @date.strftime( '%Y%m%d' )
   cache = @conf['recent_comment3.cache']
   size = @conf['recent_comment3.cache_size']
   
   if @mode == 'comment' and @comment and @comment.visible? then
      PStore.new( cache ).transaction do |db|
         comment = @comment
         serial = 0
         @diaries[date].each_comment( 100 ) do
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
         
         @diaries[date].each_comment( 100 ) do |dcomment|
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
