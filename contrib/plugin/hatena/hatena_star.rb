# hatena_star.rb
# Itoshi Nikaido <dritoshi at gmail dot com>
# Distributed under the GPL
add_header_proc do
	hatena_star = %Q|\t<script type="text/javascript" src="http://s.hatena.ne.jp/js/HatenaStar.js"></script>\n|
	hatena_star << %Q|\t<script type="text/javascript"><!--\n|
	hatena_star << %Q|\t\tHatena.Star.Token = '#{h @conf['hatena_star.token']}';\n|
	hatena_star << %Q|\t//--></script>\n|
end

add_conf_proc( 'Hatena::Star', 'Hatena::Star') do
	if( @mode == 'saveconf' ) then
		@conf['hatena_star.token'] = @cgi.params['hatena_star.token'][0]
	end
	<<-HTML
	<h3>Hatena::Star Token</h3>
	<p><input name="hatena_star.token" value="#{h @conf['hatena_star.token']}" size=42></P>
	HTML
end
