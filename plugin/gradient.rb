# gradient.rb $Revision: 1.3 $
#
# gradient.rb: 文字の大きさを変化させながら表示
#   パラメタ:
#     str:        文字列
#     first_size: 開始文字サイズ(数値、単位pt)
#     last_size:  開始文字サイズ(数値、単位pt)
#
#   例: 「こんなこともできます」を10ptから30ptに拡大
#     <%=gradient 'こんなこともできます', 10, 30 %>
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2.
#
def gradient( str, first_size, last_size )
	ary = str.split( // )
	len = ary.length - 1
	result = ""
	fontsize = first_size.to_f
	sd = ( last_size - first_size ).to_f / len
	ary.each do |x|
		s = sprintf( '%d',fontsize.round )
		result << %Q[<span style="font-size: #{s}pt;">#{h x}</span>]
		fontsize += sd
	end
	result
end

