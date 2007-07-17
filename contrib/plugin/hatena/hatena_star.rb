# hatena_star.rb
# Itoshi Nikaido <dritoshi at gmail dot com>
# Distributed under the GPL

@hatena_star_options = {
	'token' => 'Token',
	'star.image' => 'Star.ImgSrc',
	'star.add' => 'AddButton.ImgSrc',
	'comment.image' => 'CommentButton.ImgSrc',
	'comment.active' => 'CommentButton.ImgSrcActive'
}

add_header_proc do
	hatena_star = %Q|\t<script type="text/javascript" src="http://s.hatena.ne.jp/js/HatenaStar.js"></script>\n|
	hatena_star << %Q|\t<script type="text/javascript"><!--\n|
		@hatena_star_options.each do |o,v|
			hatena_star << %Q|\t\tHatena.Star.#{v} = '#{CGI::escapeHTML @conf["hatena_star.#{o}"]}';\n| if @conf["hatena_star.#{o}"]
		end
	hatena_star << %Q|\t//--></script>\n|
end

add_conf_proc( 'hatena_star', 'Hatena::Star' ) do
	if( @mode == 'saveconf' ) then
		@hatena_star_options.keys.each do |o|
			@conf["hatena_star.#{o}"] = @cgi.params["hatena_star.#{o}"][0].strip
			if @conf["hatena_star.#{o}"].length == 0 then
				@conf["hatena_star.#{o}"] = nil
			end
		end
	end
	<<-HTML
	<h3>Token</h3>
	<p><input name="hatena_star.token" value="#{CGI::escapeHTML @conf['hatena_star.token']}" size=50></P>
	<h3>Star Image (URL)</h3>
	<p><input name="hatena_star.star.image" value="#{CGI::escapeHTML @conf['hatena_star.star.image']}" size=50></P>
	<h3>Add Star Image (URL)</h3>
	<p><input name="hatena_star.star.add" value="#{CGI::escapeHTML @conf['hatena_star.star.add']}" size=50></P>
	<h3>Comment Image (URL)</h3>
	<p><input name="hatena_star.comment.image" value="#{CGI::escapeHTML @conf['hatena_star.comment.image']}" size=50></P>
	<h3>Active Comment Image (URL)</h3>
	<p><input name="hatena_star.comment.active" value="#{CGI::escapeHTML @conf['hatena_star.comment.active']}" size=50></P>
	HTML
end
