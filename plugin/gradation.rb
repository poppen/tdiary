# gradation.rb $Revision: 1.1 $
#
# gradation.rb: 文字列をグラデーション表示
#   パラメタ:
#     str:         文字列
#     first_color: グラデーション開始色(16進 6桁指定)
#     last_color:  グラデーション終了色(16進 6桁指定)
#
# Copyright (C) 2002 by zoe <http://www.kasumi.sakura.ne.jp/~zoe/tdiary/>
#
# Original: http://www.kasumi.sakura.ne.jp/~zoe/tdiary/?date=20011229#p07
# Modified: by TADA Tadashi <http://sho.tdiary.net/>
#
def gradation( str, first_color, last_color )
	ary = str.split( // )
	len = ary.length - 1
	result = ""
	r = first_color[0..1].hex.to_f
	g = first_color[2..3].hex.to_f
	b = first_color[4..5].hex.to_f
	rd = ((last_color[0..1].hex - r)/len)
	gd = ((last_color[2..3].hex - g)/len)
	bd = ((last_color[4..5].hex - b)/len)
	ary.each do |x|
		c = sprintf( '%02x%02x%02x', r, g, b )
		result << %Q[<span style="color: ##{c}">#{x}</span>]
		r += rd
		g += gd
		b += bd
	end
	result
end

