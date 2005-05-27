# add_bookmark.rb $Revision 1.0 $
#
# dayモード時の記事上部にソーシャルブックマークへのリンクを埋め込みます。
# 現在「はてなブックマーク」「del.icio.us」「MM/Memo」に対応しています。
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL

if /day/ === @mode and ! @conf.bot? and ! @conf.mobile_agent?
	add_body_enter_proc do |date|

      caption = ''
      if @conf['add.bookmark.hatena'] === "t" then
         caption += "[ <a href=\"http://b.hatena.ne.jp/append?#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_hatena}</a> ]<br>"
      end
      if @conf['add.bookmark.del'] === "t" then
         caption += "[ <a href=\"http://del.icio.us/1?url=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_del}</a> ]<br>"
      end
      if @conf['add.bookmark.mm'] === "t" then
         caption += "[ <a href=\"http://1470.net/mm/memo_form.html?url=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_mm}</a> ]"
      end

      <<-HTML
      <div class=\"body-enter\">
      #{caption}
      </div>
      HTML
   end
end


add_conf_proc( 'add_bookmark', @add_bookmark_label ) do
   add_bookmark_conf_proc
end
def add_bookmark_conf_proc
   if @mode == 'saveconf' then
      @conf['add.bookmark.hatena'] = @cgi.params['add.bookmark.hatena'][0]
      @conf['add.bookmark.del'] = @cgi.params['add.bookmark.del'][0]
      @conf['add.bookmark.mm'] = @cgi.params['add.bookmark.mm'][0]
   end

   @conf['add.bookmark.hatena'] = t unless @conf['add.bookmark.hatena']
   @conf['add.bookmark.del'] = t unless @conf['add.bookmark.del']
   @conf['add.bookmark.mm'] = t unless @conf['add.bookmark.mm']

   checked_hatena = 't' == @conf['add.bookmark.hatena'] ? ' checked' : ''
   checked_del = 't' == @conf['add.bookmark.del'] ? ' checked' : ''
   checked_mm = 't' == @conf['add.bookmark.mm'] ? ' checked' : ''

   result = <<-HTML
   <p>#{@add_bookmark_desc}</p>
   <ul>
   <li><input name="add.bookmark.hatena" type="checkbox" value="t"#{checked_hatena}>#{@label_hatena}</li>
   <li><input name="add.bookmark.del" type="checkbox" value="t"#{checked_del}>#{@label_del}</li>
   <li><input name="add.bookmark.mm" type="checkbox" value="t"#{checked_mm}>#{@label_mm}</li>
   </ul>
   HTML
end

