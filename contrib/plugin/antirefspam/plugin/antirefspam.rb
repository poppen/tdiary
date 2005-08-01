#
# antirefspam.rb 
#
# Copyright (c) 2004-2005 T.Shimomura <redbug@netlife.gr.jp>
# You can redistribute it and/or modify it under GPL2.
# Please use version 1.0.0 (not 1.0.0G) if GPL doesn't want to be forced on me.
#

add_conf_proc( 'antirefspam', 'Anti Referer Spam' ) do
	if @mode == 'saveconf'
		@conf['antirefspam.disable'] = @cgi.params['antirefspam.disable'][0]
		@conf['antirefspam.trustedurl'] = @cgi.params['antirefspam.trustedurl'][0]
		@conf['antirefspam.checkreftable'] = @cgi.params['antirefspam.checkreftable'][0]
		@conf['antirefspam.myurl'] = @cgi.params['antirefspam.myurl'][0]
		@conf['antirefspam.proxy_server'] = @cgi.params['antirefspam.proxy_server'][0]
		@conf['antirefspam.proxy_port'] = @cgi.params['antirefspam.proxy_port'][0]
		@conf['antirefspam.comment_kanaonly'] = @cgi.params['antirefspam.comment_kanaonly'][0]
		@conf['antirefspam.comment_maxsize'] = @cgi.params['antirefspam.comment_maxsize'][0]
		@conf['antirefspam.comment_ngwords'] = @cgi.params['antirefspam.comment_ngwords'][0]
	end

	<<-HTML
	#{@antispamref_html_antispamref}
	<p>
	<input type="checkbox" name="antirefspam.disable" value="true" #{if @conf['antirefspam.disable'].to_s == "true" then "checked" end}>#{@antispamref_html_disable}
	</p>

	#{@antispamref_html_myurl}
	<p><input name="antirefspam.myurl" value="#{CGI::escapeHTML( @conf['antirefspam.myurl'].to_s )}" size="70"></p>

	#{@antispamref_html_proxy}
	<p>
	server : <input name="antirefspam.proxy_server" value="#{CGI::escapeHTML( @conf['antirefspam.proxy_server'].to_s )}" size="40">
	port : <input name="antirefspam.proxy_port" value="#{CGI::escapeHTML( @conf['antirefspam.proxy_port'].to_s )}" size="5">
	</p>

	#{@antispamref_html_trustedurl}
	<textarea name="antirefspam.trustedurl" cols="70" rows="15">#{CGI::escapeHTML( @conf['antirefspam.trustedurl'].to_s )}</textarea>

	<p>
	<input type="checkbox" name="antirefspam.checkreftable" value="true" #{if @conf['antirefspam.checkreftable'].to_s == "true" then "checked" end}>#{@antispamref_html_checkreftable}
	</p>

	#{@antispamref_html_comment}
	<p>
	<input type="checkbox" name="antirefspam.comment_kanaonly" value="true" #{if @conf['antirefspam.comment_kanaonly'].to_s == "true" then "checked" end}>#{@antispamref_html_comment_kanaonly}
	</p>
	<p>
	#{@antispamref_html_comment_maxsize} <input name="antirefspam.comment_maxsize" value="#{CGI::escapeHTML( @conf['antirefspam.comment_maxsize'].to_s )}" size="8">
	</p>
	<p>
	#{@antispamref_html_comment_ngwords}
	<textarea name="antirefspam.comment_ngwords" cols="70" rows="15">#{CGI::escapeHTML( @conf['antirefspam.comment_ngwords'].to_s )}</textarea>
	</p>

	#{@antispamref_html_faq}
	HTML
end

