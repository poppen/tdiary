# search_form.rb Chinese resource. $Revision: 1.1 $

def google_form( button_name = "Google Search", size = 20, default_text = "" )
	first = %Q[<a href="http://www.google.com/">
		<img src="http://www.google.com/logos/Logo_40wht.gif" 
			style="border-width: 0px; vertical-align: middle;" alt="Google"></a>]
	search_form( "http://www.google.com/search", "q", button_name, size, default_text, first, '' )
end

def yahoo_form( button_name = "Yahoo! Search", size = 20, default_text = "" )
	first = %Q[<a href="http://www.yahoo.com/">
		<img src="http://us.i1.yimg.com/us.yimg.com/i/yahootogo/ytg_search.gif"
			style="border-width: 0px; vertical-align: middle;" alt="[Yahoo!]"></a>]
	search_form( "http://search.yahoo.com/search", "p", button_name, size, default_text, first, "" )
end
