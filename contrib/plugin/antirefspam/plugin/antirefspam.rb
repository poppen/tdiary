#
# antirefspam.rb 
#
# Copyright (c) 2004 T.Shimomura <redbug@netlife.gr.jp>
#

add_conf_proc( 'antirefspam', 'Anti Referer Spam' ) do
	if @mode == 'saveconf'
		@conf['antirefspam.trustedurl'] = @cgi.params['antirefspam.trustedurl'][0]
		@conf['antirefspam.myurl'] = @cgi.params['antirefspam.myurl'][0]
	end

	<<-HTML
	#{@antispamref_html_myurl}
	<p><input name="antirefspam.myurl" value="#{CGI::escapeHTML( @conf['antirefspam.myurl'].to_s )}" size="70"></p>

	#{@antispamref_html_trustedurl}
	<textarea name="antirefspam.trustedurl" cols="70" rows="15">#{CGI::escapeHTML( @conf['antirefspam.trustedurl'].to_s )}</textarea>

	#{@antispamref_html_faq}
	HTML
end
