# search_form.rb $Revision: 1.8 $
#
# Show a form for search engines.
#
# 1. Usage
# namazu_form(url, button_name, size, default_text
# googlej_form(button_name, size, default_text)
# yahooj_form(button_name, size, default_text)
#
# 2. Documents
# See URLs below for more details.
#   http://ponx.s5.xrea.com/hiki/search_form.rb.html (English) 
#   http://ponx.s5.xrea.com/hiki/ja/search_form.rb.html (Japanese) 
#
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

def googlej_form(button_name = "Google ¸¡º÷", size = 20, default_text = "")
	first = %Q[<a href="http://www.google.com/">
		<img src="http://www.google.com/logos/Logo_40wht.gif" 
			style="border-width: 0px; vertical-align: middle;" alt="Google"></a>]
	last = %Q[<input type=hidden name=hl value="ja"><input type=hidden name=ie value="euc-jp">]
	search_form("http://www.google.com/search", "q", button_name, size, default_text, first, last)
end

def yahooj_form(button_name = "Yahoo! ¸¡º÷", size = 20, default_text = "")
	first = %Q[<a href="http://www.yahoo.co.jp/">
		<img src="http://img.yahoo.co.jp/images/yahoojp_sm.gif" 
			style="border-width: 0px; vertical-align: middle;" alt="Yahoo! JAPAN"></a>]
	search_form("http://search.yahoo.co.jp/bin/search", "p", button_name, size, default_text, first, "")
end
