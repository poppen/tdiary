# English resource of tb-show.rb
#

def tb_show_conf_html
	<<-"HTML"
	<h3 class="subtitle">TrackBack anchor</h3>
	#{"<p>TrackBack anchor is inserted into begining of each TrackBacks from other weblogs. So You can specify '&lt;span class=\"tanchor\"&gt;_&lt;/span&gt;\">', image anchor will be shown Image anchor by themes.</p>" unless @conf.mobile_agent?}
	<p><input name="trackback_anchor" value="#{ CGI::escapeHTML(@conf['trackback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
	<h3 class="subtitle">Number of TrackBacks</h3>
	#{"<p>In Latest or Month mode, you can specify number of visible TrackBacks. So in Dayly mode, all of TrackBacks are shown.</p>" unless @conf.mobile_agent?}
	<p><input name="trackback_limit" value="#{ @conf['trackback_limit'] || @conf.comment_limit }" size="3"> TrackBacks</p>
	HTML
end

