# tb-show.rb $Revision: 1.18 $
#
# functions:
#   * show TrackBack ping URL in right of TSUKKOMI label.
#   * hide TrackBacks in TSUKKOMI.
#   * show TrackBacks above Today's Links.
#
# options:
#	@options['tb.cgi']:
#		the TrackBack ping URL. './tb.rb' is default.
#	@options['tb.hide_if_no_tb']:
#		If true, hide 'TrackBacks(n)' when there is no TrackBacks.  Default value is false.
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
# Modified: by Junichiro Kita <kita@kitaj.no-ip.com>
#
#
# If you want to show TrackBack Ping URL under comment_new link, try this.
#
#	alias :comment_new_tb_backup :comment_new
#	def comment_new
#		cgi = @options['tb.cgi'] || './tb.rb'
#		url = "#{cgi}/#{@tb_date.strftime( '%Y%m%d' )}"
#		%Q|#{comment_new_tb_backup }</a>]<br>[TrackBack to <a href="#{@tb_url}">#{@tb_url}|
#	end
#
 
# running on only non mobile mode
unless @conf.mobile_agent? then

#
# show TrackBack ping URL
#
add_body_enter_proc do |date|
	@tb_date = date
	if ENV['HTTP_HOST'] and ENV['REQUEST_URI'] then
		cgi = File.basename(@options['tb.cgi'] || './tb.rb')
		@tb_id_url = %Q|http:////#{ENV['HTTP_HOST']}#{File.dirname(ENV['REQUEST_URI'] + '.')}/#{anchor @tb_date.strftime('%Y%m%d')}|.gsub( %r|/\.?/|, '/' )
		@tb_url = %Q|http:////#{ENV['HTTP_HOST']}#{File.dirname(ENV['REQUEST_URI'] + '.')}/#{cgi}/#{@tb_date.strftime('%Y%m%d')}|.gsub( %r|/\.?/|, '/' )
	else
		@tb_id_url = @tb_url = nil
	end
	''
end

#
# make RDF
#
if @mode == 'day'
add_body_leave_proc do |date|
	if @tb_url and @diaries[@tb_date.strftime('%Y%m%d')] then
		<<-TBRDF
<!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/">
<rdf:Description
	rdf:about="#{@tb_id_url}"
	dc:identifer="#{@tb_id_url}"
	dc:title="#{CGI::escapeHTML(@diaries[@tb_date.strftime('%Y%m%d')].title).gsub(/-{2,}/) {'&#45;' * $&.size}}"
	trackback:ping="#{@tb_url}" />
</rdf:RDF>
-->
		TBRDF
	else
		''
	end
end
end

#
# hide TrackBacks in TSUKKOMI
#
eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class Comment
		def visible_true?
			@show
		end
		#{if @mode !~ /^(form|edit|showcomment)$/ then
			'def visible?
				@show and /^(Track|Ping)Back$/ !~ name
			end'
		end}
	end
end
MODIFY_CLASS

#
# insert TrackBacks above Today's Link.
#
alias :referer_of_today_short_tb_backup :referer_of_today_short
def referer_of_today_short( diary, limit )
	r = referer_of_today_short_tb_backup( diary, limit )
	return r unless @plugin_files.grep(/blog_style.rb\z/).empty?
	if diary and !bot? then
		count = 0
		diary.each_visible_trackback( 128 ) {|t,count|} # count up
		r << %Q|<a href="#{@index}#{anchor @tb_date.strftime( '%Y%m%d' )}#t">TrackBack#{count > 1 ? 's' : ''}(#{count})</a>| unless count == 0 and @options['tb.hide_if_no_tb']
	end
	r
end

def trackbacks_of_today_short( diary, limit = @conf['trackback_limit'] || 3 )
	# for BlogKit only
	return if @plugin_files.grep(/blog_style.rb\z/).empty?

	fragment = 't%02d'
	today = anchor( diary.date.strftime( '%Y%m%d' ) )
	count = 0
	diary.each_visible_trackback( limit ) {|t,count|} # count up

	r = ''
	r << %Q!\t<div class="comment trackbacks">\n!

	r << %Q!\t\t<div class="caption">\n!
	r << %Q!\t\t\t<a name="t">#{ trackback_today }#{ trackback_total( count ) }</a>\n! if count > 0
	r << %Q!\t\t\t[#{ trackback_ping_url }]\n!
	r << %Q!\t\t</div>\n!

	r << %Q!\t\t<div class="commentshort trackbackshort">\n!
	r << %Q!\t\t\t<p><a href="#{ @index }#{ today }#t01">Before...</a></p>\n! if count > limit

	diary.each_visible_trackback_tail( limit ) do |t,i|
		url, name, title, excerpt = t.body.split( /\n/,4 )
		a = name || url
		a += ':' + title if title &&! title.empty?

		r << %Q!\t\t\t<p>\n!
		r << %Q!\t\t\t\t<a href="#{ @index }#{ today }##{ fragment % i }">#{ @conf['trackback_anchor'] }</a>\n!
		r << %Q!\t\t\t\t<span class="commentator blog"><a href="#{ CGI::escapeHTML(url)}">#{ a }</a></span>\n!
		r << %Q!\t\t\t\t[<%= CGI::escapeHTML( @conf.shorten( excerpt, @conf.comment_length ) ) %>]\n! if excerpt
		r << %Q!\t\t\t</p>\n!
	end
	r << %Q!\t\t</div>\n!
	r << %Q!\t</div>\n!
	r
end

def trackbacks_of_today_long( diary, limit = 128 )
	count = 0
	diary.each_visible_trackback( limit ) {|t,count|} # count up
	fragment = 't%02d'
	today = anchor( @date.strftime( '%Y%m%d' ) )

	r = ''
	r << %Q!\t<div class="comment trackbacks">\n!

	r << %Q!\t\t<div class="caption">\n!
	r << %Q!\t\t\t<a name="t">#{ trackback_today }#{ trackback_total( count ) }</a>\n! if count > 0
	r << %Q!\t\t\t[#{ trackback_ping_url }]\n!
	r << %Q!\t\t</div>\n!

	r << %Q!\t\t<div class="commentbody trackbackbody">\n!
	diary.each_visible_trackback( limit ) do |t,i|
		url, name, title, excerpt = t.body.split( /\n/,4 )
		a = name || url
		a += ':' + title if title &&! title.empty?
		f = fragment % i

		r << %Q!\t\t\t<div class="commentator trackback">\n!
		r << %Q!\t\t\t\t<a name="#{ f }%>" href="#{ @index }#{ today }##{ f }">#{ @conf['trackback_anchor'] }</a>\n!
		r << %Q!\t\t\t\t<span class="commentator trackbackblog"><a href="#{ CGI::escapeHTML(url) }">#{ a }</a></span>\n!
		r << %Q!\t\t\t\t<span class="commenttime trackbacktime">#{ comment_date( t.date ) }</span>\n!
		r << %Q!\t\t\t\t<p>#{ CGI::escapeHTML( excerpt ).strip.gsub( /\n/,'<br>') }</p>\n! if excerpt
		r << %Q!\t\t\t</div>\n!
  	end
	r << %Q!\t\t</div>\n!
	r << %Q!\t</div>\n!
	r
end

def trackback_ping_url
	if @tb_url and not bot?
		%Q|Ping URL: <a href="#{@tb_url}">#{@tb_url}</a>|
	else
		''
	end
end

# running on only non mobile mode
end # unless mobile_agent?

# configurations
@conf['trackback_anchor'] ||= @conf.comment_anchor
@conf['trackback_limit']  ||= @conf.comment_limit

add_conf_proc( 'TrackBack', 'TrackBack' ) do
	if @mode == 'saveconf' then
		@conf['trackback_anchor'] = @conf.to_native( @cgi.params['trackback_anchor'][0] )
		@conf['trackback_limit']  = @cgi.params['trackback_limit'][0].to_i
		@conf['trackback_limit'] = 3 if @conf['trackback_limit'] < 1
	end
	<<-"HTML"
	<h3 class="subtitle">TrackBack アンカー</h3>
	#{"<p>他の weblog からの TrackBack の先頭に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class=\"tanchor\"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります多分。なってほしいな。そのうちなるに違いない。</p>" unless @conf.mobile_agent?}
	<p><input name="trackback_anchor" value="#{ CGI::escapeHTML(@conf['trackback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
	<h3 class="subtitle">TrackBack リスト表示数</h3>
	#{"<p>最新もしくは月別表示時に表示する、 TrackBack の最大件数を指定します。なお、日別表示時にはここの指定にかかわらずす最大128件の TrackBack が表示されます。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="trackback_limit" value="#{ @conf['trackback_limit'] || @conf.comment_limit }" size="3">件</p>
	HTML
end
