# add_bookmark.rb $Revision 1.3 $
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL

def bookmark_init
   @conf['add.bookmark.hatena'] ||= ""
   @conf['add.bookmark.del'] ||= ""
   @conf['add.bookmark.mm'] ||= ""
end

add_subtitle_proc do |date, index, subtitle|
   bookmark_init
   
   if @conf.mobile_agent? then
      caption = %Q|#{subtitle}|
   else
      caption = %Q|#{subtitle} |

      section_url = @conf.base_url + anchor(date.strftime('%Y%m%d')) + '#p' + ('%02d' % index)
      
      if @conf['add.bookmark.hatena'] == "t" then
         caption += %Q|<a href=\"http://b.hatena.ne.jp/append?#{h(section_url)}\"><img src=\"http://b.hatena.ne.jp/images/append.gif\" width=\"16\" height=\"12\" style =\"border: none;\" alt=\"#{@caption_hatena}\" title=\"#{@caption_hatena}\"></a> |
      end
      
      if @conf['add.bookmark.del'] == "t" then
         caption += %Q|<a href=\"http://del.icio.us/1?url=#{h(section_url)}\"><img src=\"http://del.icio.us/img/delicious.gif\" width=\"18\" height=\"18\" style=\"border: none;\" alt=\"#{@caption_del}\" title=\"#{@caption_del}\"></a> |
      end
      
      if @conf['add.bookmark.mm'] == "t" then
         caption += %Q|<a href=\"http://1470.net/mm/memo_form.html?url=#{h(section_url)}\"><img src=\"http://1470.net/img/mm_icon.gif\" width=\"21\" height=\"12\" style=\"border: none;\" alt=\"#{@caption_mm}\" title=\"#{@caption_mm}\"></a> |
      end
   end
   
   <<-HTML
   #{caption}
   HTML
end

add_conf_proc( 'add_bookmark', @add_bookmark_label ) do
   add_bookmark_conf_proc
end

def add_bookmark_conf_proc
   bookmark_init
   saveconf_add_bookmark

   bookmark_categories = [
   'add.bookmark.hatena',
   'add.bookmark.del',
   'add.bookmark.mm',
   ]

   r = ''
   r << %Q|<h3 class="subtitle">#{@add_bookmark_label}</h3><p>#{@add_bookmark_desc}</p><ul>|

   bookmark_categories.each_with_index do |idx,view|
      checked = "t" == @conf[idx] ? ' checked' : ''
      label = @bookmark_label[view]
      r << %Q|<li><input name=#{idx} type="checkbox" value="t"#{checked}>#{label}</li>|
   end
   r << %Q|</ul>|

end

if @mode == 'saveconf'
   def saveconf_add_bookmark
      @conf['add.bookmark.hatena'] = @cgi.params['add.bookmark.hatena'][0]
      @conf['add.bookmark.del'] = @cgi.params['add.bookmark.del'][0]
      @conf['add.bookmark.mm'] = @cgi.params['add.bookmark.mm'][0]
   end
end
