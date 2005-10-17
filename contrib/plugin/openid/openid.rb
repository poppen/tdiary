#
# openid.rb: Insert OpenID delegation information. $Revision: 1.1 $
#
# Copyright (C) 2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

if /^(latest|conf|saveconf)$/ =~ @mode then
	@openid_list = {
		# service => [openid.server, openid.delegate(replace #ID# as account name)]
		'TypeKey' => ['http://www.typekey.com/t/openid/', 'http://profile.typekey.com/#ID#/'],
		'Videntiry.org' => ['http://videntity.org/serverlogin?action=openid', 'http://#ID#.videntity.org/']
	}

	if @conf['openid.service'] and @conf['openid.id'] then
		add_header_proc do
			<<-HTML
			<link rel="openid.server" href="#{@openid_list[@conf['openid.service']][0]}">
			<link rel="openid.delegate" href="#{@openid_list[@conf['openid.service']][1].sub( /#ID#/, @conf['openid.id'] )}">
			HTML
		end
	end
end

add_conf_proc( 'openid', @openid_conf_label, 'etc' ) do
	if @mode == 'saveconf' then
		@conf['openid.service'] = @cgi.params['openid.service'][0]
		@conf['openid.id'] = @cgi.params['openid.id'][0]
	end

	options = ''
	@openid_list.each_key do |key|
		options << %Q|<option value="#{key}"#{(@conf['openid.service'] == key)? ' selected' : ''}>#{key}</option>\n|
	end
	<<-HTML
	<h3 class="subtitle">#{@openid_service_label}</h3>
	<p>#{@openid_service_desc}</p>
	<p><select name="openid.service">
		#{options}
	</select></p>

	<h3 class="subtitle">#{@openid_id_label}</h3>
	<p>#{@openid_id_desc}</p>
	<p><input name="openid.id" value="#{@conf['openid.id']}"></p>
	HTML
end
