def label_pingback_exclue; "PingBack Excluding List"; end
add_conf_proc('PingBack', 'PingBack') do
	saveconf_pingback
	pingback_init

	<<-HTML
	<h3 class="subtitle">URL of PingBack server</h3>
	<p><input name="pingback.url" value="#{@conf['pingback.url']}" size="100"></p>
	<h3 class="subtitle">expire time for cache</h3>
	<p><input name="pingback.expire" value="#{@conf['pingback.expire']}" size="6">secs</p>
	<h3 class="subtitle">PingBack Excluding List</h3>
	<p><textarea name="pingback.exclude" cols="70" rows="10">#{@conf['pingback.exclude']}</textarea></p>
	HTML
end
