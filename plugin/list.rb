# list.rb $Revision: 1.3 $
#
# <ol> 順番付きリスト生成
#   <%= ol l %>
#   パラメタ:
#     l: リスト文字列(\nくぎり)
#
# <ul> 順番無しリスト
#   <%= ul l , t %>
#   パラメタ:
#     l: リスト文字列(\nくぎり)
#
# Copyright (c) 2002 abbey <inlet@cello.no-ip.org>
# Distributed under the GPL.
#
=begin ChangeLog
2002-12-18 TADA Tadashi <sho@spc.gr.jp>
	* remove parameter of t and s (for HTML Strict).
=end

def ol( l, t = nil, s = nil )
	apply_plugin( %Q[<ol>#{li l}</ol>] )
end

def ul( l, t = nil)
	apply_plugin( %Q[<ul>#{li l}</ul>] )
end

def li( text )
	list = ""
	text.each do |line|
		list << ("<li>" + line.chomp + "</li>")
	end
	result = list
end

