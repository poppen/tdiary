# Japanese resource of tb-show.rb
#

def tb_show_conf_html
	<<-"HTML"
	<h3 class="subtitle">TrackBack アンカー</h3>
	#{"<p>他のweblogからのTrackBackの先頭に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class=\"tanchor\"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>" unless @conf.mobile_agent?}
	<p><input name="trackback_anchor" value="#{ CGI::escapeHTML(@conf['trackback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
	<h3 class="subtitle">TrackBack リスト表示数</h3>
	#{"<p>最新もしくは月別表示時に表示する、TrackBackの最大件数を指定します。なお、日別表示時にはここの指定にかかわらず最大100件のTrackBackが表示されます。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="trackback_limit" value="#{ @conf['trackback_limit'] || @conf.comment_limit }" size="3">件</p>
	HTML
end
