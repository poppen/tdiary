# tb-send.rb $Revision: 1.1 $
#
# Copyright (c) 2003 Junichiro Kita <kita@kitaj.no-ip.com>
# You can distribute this file under the GPL.
#

add_edit_proc do |date|
	<<FORM
<div class="trackback">
Send TrackBack to URL <input class="field" name="url" size="80" value=""><br>
Excerpt: <textarea name="excerpt" cols="80" rows="3"></textarea>
</div>
FORM
end

add_update_proc do
	if /^(append|replace)$/ === @mode
		require 'net/http'
		require 'uri/http'

		url = @cgi.params['url'][0]
		break if url.nil? or url == ''
		title = @cgi.params['title'][0]
		excerpt = @cgi.params['excerpt'][0]
		blog_name = @conf.html_title

		my_url = "http://#{ENV['SERVER_NAME']}"
		my_url << ENV['REQUEST_URI'].sub(Regexp.new(Regexp.escape(@conf.update)), '')
		my_url << @conf.index.sub(%r|^\./|, '')
		my_url << anchor(@date.strftime('%Y%m%d'))

		body = "url=#{CGI::escape(my_url)}"
		body << ";title=#{CGI::escape(title.to_euc)}" unless title == ''
		body << ";excerpt=#{CGI::escape(excerpt.to_euc)}" unless excerpt == ''
		body << ";blog_name=#{CGI::escape(blog_name)}"

		remote = URI.parse(url.untaint)
		Net::HTTP.version_1_1
		Net::HTTP.start(remote.host, remote.port) do |http|
			response, = http.post(remote.request_uri, body,
										 "Content-Type" => 'application/x-www-form-urlencoded')
		end
	end
end
