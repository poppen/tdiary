# gradient.rb $Revision: 1.1 $
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
# Copyright (C) 2002 by zoe <http://www.kasumi.sakura.ne.jp/~zoe/tdiary/>
#
# Original: http://www.kasumi.sakura.ne.jp/~zoe/tdiary/?date=20020122#p02
# Modified: by TADA Tadashi <http://sho.tdiary.net/>
#
def gradient( str, first_size, last_size )
	ary = str.split( // )
	len = ary.length - 1
	result = ""
	fontsize = first_size.to_f
	sd = ( last_size - first_size ).to_f / len
	ary.each do |x|
		s = sprintf( '%d',fontsize.round )
		result << %Q[<span style="font-size: #{s}pt;">#{x}</span>]
		fontsize += sd
	end
	result
end

