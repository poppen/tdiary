# tb-send.rb $Revision: 1.6 $
#
# Copyright (c) 2003 Junichiro Kita <kita@kitaj.no-ip.com>
# You can distribute this file under the GPL.
#

add_edit_proc do |date|
	url = @cgi.params['plugin_tb_url'][0] || ''
	excerpt = @cgi.params['plugin_tb_excerpt'][0] || ''
	<<FORM
<h3 class="subtitle">TrackBack</h3>
<div class="trackback">
<div class="field title">
#{trackback_ping_send} <input class="field" tabindex="500" name="plugin_tb_url" size="60" value="#{CGI::escapeHTML( url )}">
</div>
<div class="textarea">
#{trackback_ping_excerpt} <textarea tabindex="501" style="height: 4em;" name="plugin_tb_excerpt" cols="70" rows="4">#{CGI::escapeHTML( excerpt )}</textarea>
</div>
</div>
FORM
end

if /^(append|replace)$/ =~ @mode then
	require 'net/http'

	url = @cgi.params['plugin_tb_url'][0]
	unless url.nil? or url.empty?
		title = @cgi.params['title'][0]
		excerpt = @cgi.params['plugin_tb_excerpt'][0]
		blog_name = @conf.html_title

		if excerpt.empty?
			date = @date.strftime('%Y%m%d')
			excerpt = @diaries[date].class.new(date, title, @cgi.params['body'][0]).to_html({})
		end

		old_apply_plugin = @options['apply_plugin']
		@options['apply_plugin'] = true
		excerpt = apply_plugin(excerpt, true)
		@options['apply_plugin'] = old_apply_plugin

		if excerpt.length > 255
			excerpt = @conf.shorten( excerpt.gsub( /\r/, '' ).gsub( /\n/, "\001" ), 252 ).gsub( /\001/, "\n" ) + '...'
		end

		my_url = %Q|#{@conf.base_url}#{@conf.index}#{anchor(@date.strftime('%Y%m%d'))}|.sub(%r|/\./|, '/')

		trackback = "url=#{CGI::escape(my_url)}"
		trackback << "&charset=#{trackback_ping_charset}"
		trackback << "&title=#{CGI::escape( @conf.to_native( title ) )}" unless title.empty?
		trackback << "&excerpt=#{CGI::escape( @conf.to_native( excerpt) )}" unless excerpt.empty?
		trackback << "&blog_name=#{CGI::escape(blog_name)}"

		if %r|^http://([^/]+)(/.*)$| =~ url then
			request = $2
			host, port = $1.split( /:/, 2 )
			port = '80' unless port
			Net::HTTP.version_1_1
			begin
				Net::HTTP.start( host.untaint, port.to_i ) do |http|
					response, = http.post( request, trackback,
						"Content-Type" => 'application/x-www-form-urlencoded')
					
					error = response.body.scan(%r|<error>(\d)</error>|)[0][0]
					if error == '1'
						reason = response.body.scan(%r|<message>(.*)</message>|m)[0][0]
						raise TDiaryTrackBackError.new(reason)
					end
				end
			rescue
				raise TDiaryTrackBackError.new("when sending TrackBack Ping: #{$!.message}")
			end
		end
	end
end

# vim: ts=3
