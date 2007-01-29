#
# akismet.rb: tDiary comment spam filter using Akismet API setup plugin. $Revision: 1.1 $
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp> 2007.
# Distributed under GPL2.
#

require 'net/http'
require 'uri'

add_conf_proc( 'akismet', @akismet_label_conf, 'security' ) do
	akismet_conf_proc
end

def akismet_conf_proc
	if @mode == 'saveconf' then
		@conf['akismet.enable'] = (@cgi.params['akismet.enable'][0] == 'true')
		@conf['akismet.key'] = @cgi.params['akismet.key'][0]
		if @conf['akismet.enable'] and (@conf['akismet.key'] || '').length > 0 then
			verify = akismet_verify_key?( @conf['akismet.key'] )
		end
	end

	result = <<-HTML
		<p>#{@akismet_desc}</p>

		<h3>#{@akismet_label_enable}</h3>
		<p>#{@akismet_label_enable2}<select name="akismet.enable">
			<option value="true"#{" selected" if @conf['akismet.enable']}>#{@akismet_option_enable}</option>
			<option value="false"#{" selected" unless @conf['akismet.enable']}>#{@akismet_option_disable}</option>
		</select></p>

		<h3>#{@akismet_label_key}</h3>
	HTML
	unless verify then
		result << %Q[<p class="message">#{@akismet_warn_key}</p>]
		@conf['akismet.enable'] = false
	end
	result << <<-HTML
		<p>#{@akismet_desc_key}: <input name="akismet.key" value="#{h( @conf['akismet.key'] || '')}" size="15"></p>
	HTML
end

def akismet_verify_key?( key )
	uri = URI::parse( 'http://rest.akismet.com/1.1/verify-key' )
	blog = @conf.index.dup
	blog[0, 0] = @conf.base_url unless %r|^https?://|i =~ blog
	blog.gsub!( %r|/\./|, '/' )
	data = "key=#{key}&blog=#{blog}"
	header = {
		'User-Agent' => "tDiary/#{TDIARY_VERSION} | Akismet filter",
		'Content-Type' => 'application/x-www-form-urlencoded'
	}
	body = nil
	proxy_h, proxy_p = (@conf['proxy'] || '').split( /:/ )
	::Net::HTTP::Proxy( proxy_h, proxy_p ).start( uri.host, uri.port ) do |http|
		res, body = http.post( uri.path, data, header )
	end
	return (body == 'valid')
end
