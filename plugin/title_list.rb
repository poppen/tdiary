# titile_list.rb $Revision: 1.15 $
#
# title_list: 現在表示している月のタイトルリストを表示
#   パラメタ(カッコ内は未指定時の値):
#     rev:       逆順表示(false)
#
# 備考: タイトルリストを日記に埋め込むは、レイアウトを工夫しなければ
# なりません。ヘッダやフッタでtableタグを使ったり、CSSを書き換える必
# 要があるでしょう。
#
def title_list( rev = false, extra_erb = 'obsolete' )
	result = ''
	if extra_erb != 'obsolete'
		result << %Q|<p class="message">option 'extra_erb' is obsolete!<p>|
	end
	keys = @diaries.keys.sort
	keys = keys.reverse if rev
	keys.each do |date|
		next unless @diaries[date].visible?
		result << %Q[<p class="recentitem"><a href="#{@index}#{anchor date}">#{@diaries[date].date.strftime( @date_format )}</a></p>\n<div class="recentsubtitles">\n]
		if !@plugin_files.grep(/\/category.rb$/).empty? and @diaries[date].categorizable?
			@diaries[date].each_section do |section|
				result << %Q[#{section.stripped_subtitle_to_html}<br>\n] if section.stripped_subtitle
			end
		else
			@diaries[date].each_section do |section|
				result << %Q[#{section.subtitle_to_html}<br>\n] if section.subtitle
			end
		end
		result << "</div>\n"
	end
	apply_plugin( result )
end

