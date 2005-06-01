# add_bookmark.rb $Revision 1.7 $
#
# dayモード時の記事上部にソーシャルブックマークへのリンクを埋め込みます。
# 現在「はてなブックマーク」「del.icio.us」「MM/Memo」に対応しています。
#
# Changelog:
# *1.1:@confの値判定を==に変更、dayモード判別を==に変更
# *1.2:webshotsに対応
# *1.3:fc2ブックマークに対応
# *1.4:イテレータを使うように変更
# *1.5:LiVEMARKに対応
# *1.6:はてなブックマーク、del.icio.us、MM/Memoはアイコンを使用するように変更
# *1.7:アイコン使用の選択機能を追加
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL

if @mode == "day" and ! @conf.bot? and ! @conf.mobile_agent?
  add_body_enter_proc do |date|
    
      caption = ''
      sep = ''

      if @conf['add.bookmark.hatena'] == "t" then
        caption += "[ <a href=\"http://b.hatena.ne.jp/append?#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">"
        if @conf['bookmark.icon'] == "t" then
          caption += "<img src=\"http://d.hatena.ne.jp/images/b_entry.gif\" width=\"16\" height=\"12\" style =\"border: none;\" alt=\"#{@caption_hatena}\" title=\"#{@caption_hatena}\" />"
        else
          caption += "#{@caption_hatena}"
        end
        caption += "</a> ]"
      end
      caption += sep

      if @conf['add.bookmark.del'] == "t" then
        caption += "[ <a href=\"http://del.icio.us/1?url=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}&title=\">"
        if @conf['bookmark.icon'] == "t" then
          caption += "<img src=\"http://del.icio.us/img/delicious.gif\" width=\"18\" height=\"18\" style=\"border: none;\" alt=\"#{@caption_del}\" title=\"#{@caption_del}\" />"
        else
          caption += "#{@caption_del}"
        end
        caption += "</a> ]"
      end
      caption += sep

      if @conf['add.bookmark.mm'] == "t" then
        caption += "[ <a href=\"http://1470.net/mm/memo_form.html?url=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">"
        if @conf['bookmark.icon'] == "t" then
          caption += "<img src=\"http://1470.net/img/mm_icon.gif\" width=\"21\" height=\"12\" style=\"border: none;\" alt=\"#{@caption_mm}\" title=\"#{@caption_mm}\" />"
        else
          caption += "#{@caption_mm}"
        end
        caption += "</a> ]"
      end
      caption += sep

      if @conf['add.bookmark.webshots'] == "t" then
         caption += "[ <a href=\"http://s.phpspot.org/?m=regist&u=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_webshots}</a> ]"
      end
      caption += sep
      if @conf['add.bookmark.fc2'] == "t" then
         caption += "[ <a href=\"http://bookmark.fc2.com/s/?m=regist&t=&u=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}\">#{@caption_fc2}</a> ]"
      end
      caption += sep
      if @conf['add.bookmark.live'] == "t" then
         caption += "[ <a href=\"http://livemark.jp/mgr/markIt.jsp?mode=D&url=#{@conf.base_url}#{anchor @date.strftime('%Y%m%d')}&title=\">#{@caption_live}</a> ]"
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
      'add.bookmark.fc2',
      'add.bookmark.live'
   ]

   if @mode == 'saveconf' then
      bookmark_categories.each do |idx|
         @conf[idx] = @cgi.params[idx][0]
      end
      @conf['bookmark.icon'] = @cgi.params['bookmark.icon'][0]
   end

   bookmark_categories.each do |idx|
      @conf[idx] = t unless @conf[idx]
   end

   r = ''
   @conf['bookmark.icon'] = t unless @conf['bookmark.icon']
   checked = 't' == @conf['bookmark.icon'] ? ' checked' : ''
   r << %Q|<h3>#{@used_icon_label}</h3>|
   r << %Q|<p><input name="bookmark.icon" type="checkbox" value="t"#{checked}>#{@icon_label}</p>|

   r << %Q|<h3>#{@add_bookmark_label}</h3><p>#{@add_bookmark_desc}</p><ul>|
   bookmark_categories.each_with_index do |idx,view|
      checked = 't' == @conf[idx] ? ' checked' : ''
      label = @bookmark_label[view]
      r << %Q|<li><input name=#{idx} type="checkbox" value="t"#{checked}>#{label}</li>|
   end
   r << %Q|</ul>|

end

