# tb-show.rb $Revision: 1.13 $
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
	if diary and !bot? then
		count = 0
		diary.each_comment( 100 ) do |com, idx|
			next unless com.visible_true?
			count += 1 if /^(Track|Ping)Back$/ =~ com.name
		end
		r << %Q|<a href="#{@index}#{anchor @tb_date.strftime( '%Y%m%d' )}#t">TrackBack#{count > 1 ? 's' : ''}(#{count})</a>| unless count == 0 and @options['tb.hide_if_no_tb']
	end
	r
end
 
alias :referer_of_today_long_tb_backup :referer_of_today_long
def referer_of_today_long( diary, limit )
	r = ''
	if diary then
		r << %Q[<div class="caption"><a name="t">TrackBacks</a>#{trackback_ping_url}</div>\n]
		r << %Q[	<div class="commentbody">\n]
		i = "01"
		diary.each_comment( 100 ) do |com, idx|
			next unless com.visible_true?
			next unless /^(Track|Ping)Back$/ =~ com.name
			url, blog_name, title, excerpt = com.body.split(/\n/, 4)

			blog_name ||= ''
			title ||= ''
			excerpt ||= ''

			a = blog_name
			a += ':' + title unless title.empty?
			a = url if a.empty?

			r << <<TBSHOW
		<div class="commentator">
			<a name="t#{i}" href="#{@index}#{anchor @date.strftime("%Y%m%d#t#{i}")}">#{@conf.comment_anchor}
			<span class="commentator"><a href="#{CGI::escapeHTML( url )}">#{CGI::escapeHTML( a )}</a></span>
			<span class="commenttime">#{comment_date(com.date)}</span>
		</div>
TBSHOW
			r << %Q|<p>#{CGI::escapeHTML( excerpt ).gsub( /\n/, '<br>' ).gsub( /<br><br>\Z/, '' )}</p>\n| unless excerpt.empty?
			i = i.succ
		end
		r << %Q|	</div>\n</div>\n<div class="refererlist">|
	end
	r << referer_of_today_long_tb_backup( diary, limit )
end

def trackback_ping_url
	if @tb_url and not bot?
		%Q| (TrackBack Ping URL: <a href="#{@tb_url}">#{@tb_url}</a>)|
	else
		''
	end
end

# running on only non mobile mode
end # unless mobile_agent?
