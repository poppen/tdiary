# ping.rb: $Revision: 1.1 $
#
# ping to weblog ping servers.
#
# Copyright (c) 2004 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
add_update_proc do
	list = @conf['ping.list'].split
	ping( list ) unless list.empty?
end

def ping( list )
	xml = @ping_encoder.call( <<-XML )
<?xml version="1.0" encoding="#{@ping_encode}"?>
<methodCall>
  <methodName>weblogUpdates.ping</methodName>
  <params>
    <param>
      <value>#{@conf.html_title}</value>
    </param>
    <param>
      <value>#{@conf.base_url}</value>
    </param>
  </params>
</methodCall>
	XML

	require 'net/http'
	Net::HTTP.version_1_1
	list.each do |url|
		if %r|^http://([^/]+)(.*)$| =~ url then
			begin
				request = $2.empty? ? '/' : $2
				host, port = $1.split( /:/, 2 )
				port = '80' unless port
				Net::HTTP.start( host.untaint, port.to_i ) do |http|
					response, = http.post( request, xml, 'Content-Type' => 'text/xml' )
				end
			rescue
			end
		end
	end
end

add_conf_proc( 'ping', @ping_label_conf ) do
	ping_conf_proc
end

def ping_conf_proc
	if @mode == 'saveconf' then
		@conf['ping.list'] = @cgi.params['ping.list'][0]
	end
	@conf['ping.list'] = '' unless @conf['ping.list']

	result = <<-HTML
		<h3>#{@ping_label_list}</h3>
		<p>#{@ping_label_list_desc}</p>
		<p><textarea name="ping.list" cols="70" rows="5">#{CGI::escapeHTML( @conf['ping.list'] )}</textarea></p>
	HTML
end
