# tb-send.rb $Revision: 1.3 $
#
# Copyright (c) 2003 Junichiro Kita <kita@kitaj.no-ip.com>
# You can distribute this file under the GPL.
#

add_edit_proc do |date|
	url = @cgi.params['plugin_tb_url'][0] || 'http://'
	excerpt = @cgi.params['plugin_tb_excerpt'][0] || ''
	<<FORM
<div class="trackback">
Send TrackBack to URL <input class="field" name="plugin_tb_url" size="80" value="#{CGI::escapeHTML( url )}"><br>
Excerpt: <textarea name="plugin_tb_excerpt" cols="80" rows="3">#{CGI::escapeHTML( excerpt )}</textarea>
</div>
FORM
end

if /^(append|replace)$/ =~ @mode then
	require 'net/http'

	url = @cgi.params['plugin_tb_url'][0]
	break if url.nil? or url == ''
	title = @cgi.params['title'][0]
	excerpt = @cgi.params['plugin_tb_excerpt'][0]
	blog_name = @conf.html_title

	my_url = "http://#{ENV['HTTP_HOST']}"
	my_url << ENV['REQUEST_URI'].sub(Regexp.new(Regexp.escape(@conf.update.sub(%r|^\./|, ''))), '')
	my_url << @conf.index.sub(%r|^\./|, '')
	my_url << anchor(@date.strftime('%Y%m%d'))

	body = "url=#{CGI::escape(my_url)}"
	body << ";title=#{CGI::escape(title.to_euc)}" unless title == ''
	body << ";excerpt=#{CGI::escape(excerpt.to_euc)}" unless excerpt == ''
	body << ";blog_name=#{CGI::escape(blog_name)}"

	if %r|^http://([^/]+)(/.*)$| =~ url then
		request = $2
		host, port = $1.split( /:/, 2 )
		port = '80' unless port
		Net::HTTP.version_1_1
		Net::HTTP.start( host.untaint, port.to_i ) do |http|
			response, = http.post( request, body,
					 "Content-Type" => 'application/x-www-form-urlencoded')
			$stderr.puts response.body
		end
	end
end
