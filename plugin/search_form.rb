# search_form.rb $Revision: 1.2 $
#
# 各種検索エンジンの検索フォーム表示プラグイン
#
# namazu_form: Namazu用
#		パラメタ：
# 			url:				検索エンジンのURL(例：/namazu/namazu.cgi)
# 			button_name:	ボタン名称(省略可)
# 			size:				テキストボックスの幅(省略可)
# 			default_text:	テキストボックスの初期表示文字(省略可)
#
# googlej_form: Google用
#		パラメタ：
# 			button_name:	ボタン名称(省略可)
# 			size:				テキストボックスの幅(省略可)
# 			default_text:	テキストボックスの初期表示文字(省略可)
#
# yahooj_form: Yahoo!用
# 			button_name:	ボタン名称(省略可)
# 			size:				テキストボックスの幅(省略可)
# 			default_text:	テキストボックスの初期表示文字(省略可)
# lycosj_form: Lycos用
# 			button_name:	ボタン名称(省略可)
# 			size:				テキストボックスの幅(省略可)
#
# Copyright (c) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Distributed under the same license terms as tDiary.
# 
=begin ChangeLog
2002-04-01 MUTOH Masao <mutoh@highway.ne.jp>
	* tab = 3, 文書の体裁を整えた
2002-03-24 MUTOH Masao <mutoh@highway.ne.jp>
	* Namazu, Google, Yahoo!, Lycosの検索フォームをサポート
	* version 1.0.0
=end

def search_form(url, query, button_name = "Search", size = 20, 
						default_text = "", first_form = "", last_form = "")
%Q[
	<form class="search" method="GET" action="#{url}">
	#{first_form}
		<input class="search" type="text" name="#{query}" size="#{size}" value="#{default_text}">
		<input class="search" type="submit" value="#{button_name}">
	#{last_form}
	</form>
]
end

def namazu_form(url, button_name = "Search", size = 20, default_text = "")
	search_form(url, "query", button_name, size, default_text)
end

def googlej_form(button_name = "Google 検索", size = 20, default_text = "")
	first = %Q[<a href="http://www.google.com/">
		<img src="http://www.google.com/logos/Logo_40wht.gif" 
			border="0" alt="Google" align="absmiddle"></a>]
	last = %Q[<input type=hidden name=hl value="ja">]
	search_form("http://www.google.com/search", "q", button_name, size, default_text, first, last)
end

def yahooj_form(button_name = "Yahoo! 検索", size = 20, default_text = "")
	search_form("http://search.yahoo.co.jp/bin/search", "p", button_name, size, default_text)
end

def lycosj_form(button_name = " 検索 ", size = 20)
	first = %Q[ <a href="http://www.lycos.co.jp/">
							<img src="http://www.lycos.co.jp/images/logo_link.gif" 
								alt="Lycos" width="70" height="20" border="0"></a>]
	search_form("http://search.lycos.co.jp/main.html", "query", button_name, size, "", first)
end
