# titile_list.rb $Revision: 1.5 $
#
# title_list: 現在表示している月のタイトルリストを表示
#   パラメタ(カッコ内は未指定時の値):
#     rev:       逆順表示(false)
#     extra_erb: タイトルリスト生成後さらにERbを通すか(false)
#
# 備考: タイトルリストを日記に埋め込むは、レイアウトを工夫しなければ
# なりません。ヘッダやフッタでtableタグを使ったり、CSSを書き換える必
# 要があるでしょう。
#
def title_list( rev = false, extra_erb = false )
	result = ''
	keys = @diaries.keys.sort
	keys = keys.reverse if rev
	keys.each do |date|
		next unless @diaries[date].visible?
		result << %Q[<p class="recentitem"><a href="#{@index}#{anchor date}">#{@diaries[date].date.strftime( @date_format )}</a></p>\n<div class="recentsubtitles">\n]
		@diaries[date].each_paragraph do |paragraph|
			result << %Q[#{paragraph.subtitle}<br>\n] if paragraph.subtitle
		end
		result << "</div>\n"
	end
	if extra_erb and /<%=/ === result
		result.untaint if $SAFE < 3
		ERbLight.new( result ).result( binding )
	else
		result
	end
end

