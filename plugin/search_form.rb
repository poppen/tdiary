# search_form.rb $Revision: 1.6 $
# -pv-
#
# 名称：
# 検索フォーム表示プラグイン
#
# 概要：
# Namazu, Google, Yahoo!用の検索フォームを表示します。
#
# 使う場所：
# ヘッダ、もしくはフッタ
#
# 使い方：
# namazu_form(url, button_name, size, default_text): Namazu用
# 			url:				検索エンジンのURL(例：/namazu/namazu.cgi)
# 			button_name:	ボタン名称(省略可)
# 			size:				テキストボックスの幅(省略可)
# 			default_text:	テキストボックスの初期表示文字(省略可)
#
# googlej_form(button_name, size, default_text): Google用
# 			button_name:	ボタン名称(省略可)
# 			size:				テキストボックスの幅(省略可)
# 			default_text:	テキストボックスの初期表示文字(省略可)
#
# yahooj_form(button_name, size, default_text): Yahoo!用
# 			button_name:	ボタン名称(省略可)
# 			size:				テキストボックスの幅(省略可)
# 			default_text:	テキストボックスの初期表示文字(省略可)
#
# 注意：
# 各社検索エンジンをご利用になる際は、それぞれのサイトでライセンス等を
# 確認してください。
# 
# その他：
# 詳しくは、http://home2.highway.ne.jp/mutoh/tools/ruby/ja/search_form.html
# を参照してください。
#
# 著作権について：
# Copyright (c) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Distributed under the same license terms as tDiary.
# 
def search_form(url, query, button_name = "Search", size = 20, 
						default_text = "", first_form = "", last_form = "")
%Q[
	<form class="search" method="GET" action="#{url}">
	<div class="search">
	#{first_form}
		<input class="search" type="text" name="#{query}" size="#{size}" value="#{default_text}">
		<input class="search" type="submit" value="#{button_name}">
	#{last_form}
	</div>
	</form>
]
end

def namazu_form(url, button_name = "Search", size = 20, default_text = "")
	search_form(url, "query", button_name, size, default_text)
end

def googlej_form(button_name = "Google 検索", size = 20, default_text = "")
	first = %Q[<a href="http://www.google.com/">
		<img src="http://www.google.com/logos/Logo_40wht.gif" 
			style="border-width: 0px; vertical-align: middle;" alt="Google"></a>]
	last = %Q[<input type=hidden name=hl value="ja"><input type=hidden name=ie value="euc-jp">]
	search_form("http://www.google.com/search", "q", button_name, size, default_text, first, last)
end

def yahooj_form(button_name = "Yahoo! 検索", size = 20, default_text = "")
	first = %Q[<a href="http://www.google.com/">
		<img src="http://img.yahoo.co.jp/images/yahoojp_sm.gif" 
			style="border-width: 0px; vertical-align: middle;" alt="Yahoo! JAPAN"></a>]
	search_form("http://search.yahoo.co.jp/bin/search", "p", button_name, size, default_text, first, "")
end
