# $Revision: 1.20 $
# recent_comment3: 最近のツッコミをリストアップする
#
#   @secure = true な環境では動作しません．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'

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
end

def recent_comment3(ob_max = 'OBSOLUTE' ,sep = 'OBSOLUTE',ob_date_format = 'OBSOLUTE',*ob_except )
	return '' if @conf.secure

   recent_comment3_init
   
   cache = @conf['recent_comment3.cache']
   max = @conf['recent_comment3.max']
   date_format = @conf['recent_comment3.date_format'] 
   except = @conf['recent_comment3.except_list'].split(/,/)
	format = @conf['recent_comment3.format']
   
   result = []
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

         result << "<li>"
			result << recent_comment3_format(format, idx, a, popup, str, date_str)
			result << "</li>\n"
      end
		db.abort
   end
   if result.size == 0
      ''
   else
      %Q|<ol class="recent-comment">\n| + result.join( '' ) + "</ol>\n"
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
   end
end

# vim: ts=3
