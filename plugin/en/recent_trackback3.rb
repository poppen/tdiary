# ja/recent_trackback3.rb $Revision: 1.1 $
#
# English resources for recent_trackback3.rb
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
add_conf_proc('RecentTrackBack3', 'RecentTrackBack3') do
	saveconf_recent_trackback3
	recent_trackback3_init

	<<-HTML
	<h3 class="subtitle">The number of trackbacks</h3>
	<p>Max <input name="recent_trackback3.n" value="#{@conf['recent_trackback3.n']}" size="3"> entries</p>
	<h3 class="subtitle">Separator between each trackback</h3>
	<p><input name="recent_trackback3.sep" value="#{CGI.escapeHTML(@conf['recent_trackback3.sep'])}" size="20"></p>
	<h3 class="subtitle">Format specification for date</h3>
	<p>See <a href="http://www.rubycentral.com/ref/ref_c_time.html#strftime">ruby's reference manual</a>.</p>
	<p><input name="recent_trackback3.date_format" value="#{CGI.escapeHTML(@conf['recent_trackback3.date_format'])}" size="40"></p>
	<h3 class="subtitle">Template</h3>
	<p>Specify how each trackback is rendered.</p>
	<textarea name="recent_trackback3.format" cols="70" rows="3">#{CGI.escapeHTML(@conf['recent_trackback3.format'])}</textarea>
	<p><em>$digit</em> in the template is replaced as follows.</p>
	<dl>
		<dt>$1</dt><dd>index</dd>
		<dt>$2</dt><dd>the TrackBack's URL</dd>
		<dt>$3</dt><dd>the TrackBack's excerpt</dd>
		<dt>$4</dt><dd>the sender of the TrackBack</dd>
		<dt>$5</dt><dd>when the TrackBack is received</dd>
	</dl>
	HTML
end
end
# vim: ts=3
