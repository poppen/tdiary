# add_bookmark.rb $Revision 1.4 $
#
# dayモード時の記事上部にソーシャルブックマークへのリンクを埋め込みます。
# 現在「はてなブックマーク」「del.icio.us」「MM/Memo」に対応しています。
# 
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL

if @mode == "day" and ! @conf.bot? and ! @conf.mobile_agent?
	add_body_enter_proc do |date|

      caption = ''

      if @conf['add.bookmark.hatena'] == "t" then
         caption += "[ <a href=\"http://b.hatena.ne.jp/append?#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_hatena}</a> ]<br>"
      end
      if @conf['add.bookmark.del'] == "t" then
         caption += "[ <a href=\"http://del.icio.us/1?url=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_del}</a> ]<br>"
      end
      if @conf['add.bookmark.mm'] == "t" then
         caption += "[ <a href=\"http://1470.net/mm/memo_form.html?url=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_mm}</a> ]<br>"
      end
      if @conf['add.bookmark.webshots'] == "t" then
         caption += "[ <a href=\"http://s.phpspot.org/?m=regist&u=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_webshots}</a> ]<br>"
      end
      if @conf['add.bookmark.fc2'] == "t" then
         caption += "[ <a href=\"http://bookmark.fc2.com/s/?m=regist&t=&u=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_fc2}</a> ]"
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
   bookmark_categories = [
      'add.bookmark.hatena',
      'add.bookmark.del',
      'add.bookmark.mm',
      'add.bookmark.webshots',
      'add.bookmark.fc2'
   ]

   if @mode == 'saveconf' then
      bookmark_categories.each do |idx|
         @conf[idx] = @cgi.params[idx][0]
      end
   end

   bookmark_categories.each do |idx|
      @conf[idx] = t unless @conf[idx]
   end

   r = "<p>#{@add_bookmark_desc}</p><ul>"
   bookmark_categories.each_with_index do |idx,view|
      checked = 't' == @conf[idx] ? ' checked' : ''
      label = @bookmark_label[view]
      r << %Q|<li><input name=#{idx} type="checkbox" value="t"#{checked}>#{label}</li>|
   end
   r << %Q|</ul>|
end

