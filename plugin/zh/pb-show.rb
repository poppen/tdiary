# English resource of pb-show.rb
#
def pingback_today; "Today's PingBacks"; end
def pingback_total( total ); "(Total: #{total})"; end
def pb_show_conf_html
  <<-"HTML"
  <h3 class="subtitle">PingBack anchor</h3>
  #{"<p>PingBack anchor is inserted into begining of each PingBacks from other weblogs. So You can specify '&lt;span class=\"tanchor\"&gt;_&lt;/span&gt;\">', image anchor will be shown Image anchor by themes.</p>" unless @conf.mobile_agent?}
  <p><input name="trackback_anchor" value="#{ CGI::escapeHTML(@conf['trackback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
  <h3 class="subtitle">Number of PingBacks</h3>
  #{"<p>In Latest or Month mode, you can specify number of visible PingBacks. So in Dayly mode, all of PingBacks are shown.</p>" unless @conf.mobile_agent?}
  <p><input name="trackback_limit" value="#{ @conf['trackback_limit'] || @conf.comment_limit }" size="3"> PingBacks</p>
  HTML
end
