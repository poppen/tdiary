# list.rb $Revision: 1.1 $
#
# <ol> 順番付きリスト生成
#   <%= ol l, t, s %>
#   パラメタ:
#     l: リスト文字列(\nくぎり)
#     t: 項目番号のタイプ。
#        1,a,A,i,I
#        デフォルトは 1
#     s: 開始番号
#        デフォルトは 1
#     (t,sは省略可能)
#
# <ul> 順番無しリスト
#   <%= ul l , t %>
#   パラメタ:
#     l: リスト文字列(\nくぎり)
#     t: 項目マークのタイプ。
#          d:黒丸
#          c:白丸
#          s:四角
#        デフォルトはd
#     tは省略可能
#
# Copyright (c) 2002 abbey <inlet@cello.no-ip.org>
# Distributed under the GPL.
# 

def ol( l, t = "1", s = "1" )
	%Q[<ol type="#{t}" start="#{s}">#{li l}</ol>]
end

def ul( l, t = "")
	t2 = "disc"
	if t == "c"
		t2 = "circle"
	elsif t == "s"
		t2 = "square"
	end       
	%Q[<ul type="#{t2}">#{li l}</ul>]
end

def li( text )
	list = ""
	text.each do |line|
		list << ("<li>" + line.chomp + "</li>")
	end
	result = list
end

