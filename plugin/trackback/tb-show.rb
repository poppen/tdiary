# tb-show.rb $Revision: 1.1 $
#
# functions:
#   * show TrackBack ping URL in right of TSUKKOMI label.
#   * hide TrackBacks in TSUKKOMI.
#   * show TrackBacks above Today's Links.
#
# options:
#	@options['tb.cgi']:
#		the TrackBack ping URL. './tb.rb' is default.
#	@options['tb.url_position']:
#		where to show TrackBack Ping URL. 'upper' or 'lower'.
#		'upper' is default.
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
# Modified: by Junichiro Kita <kita@kitaj.no-ip.com>
#
 
#
# show TrackBack ping URL
#
add_body_enter_proc do |date|
	@tb_date = date
	cgi = File.basename(@options['tb.cgi'] || './tb.rb')
	@tb_id_url = %Q|http://#{ENV['SERVER_NAME']}#{ENV['SERVER_PORT'] == '80' ? '' : ':'+ENV['SERVER_PORT']}#{File.dirname(ENV['REQUEST_URI'])}/#{anchor @tb_date.strftime('%Y%m%d')}|
	@tb_url = %Q|http://#{ENV['SERVER_NAME']}#{ENV['SERVER_PORT'] == '80' ? '' : ':'+ENV['SERVER_PORT']}#{File.dirname(ENV['REQUEST_URI'])}/#{cgi}/#{@tb_date.strftime('%Y%m%d')}|
	if @options['tb.url_position'] != 'lower'
		%Q|<div class="body-enter"><p><span class="trackback-url">TrackBack Ping URL: #{@tb_url}</span></p></div>\n|
	else
		''
	end
end

add_body_leave_proc do |date|
	if @options['tb.url_position'] == 'lower'
		%Q|<div class="body-leave"><p><span class="trackback-url">TrackBack Ping URL: #{@tb_url}</span></p></div>\n|
	else
		''
	end
end

#
# make RDF
#
add_body_leave_proc do |date|
	<<TBRDF
<!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/">
<rdf:Description
	rdf:about="#{@tb_id_url}"
	dc:identifer="#{@tb_id_url}"
	dc:title="#{@diaries[@tb_date.strftime('%Y%m%d')].title}"
	trackback:ping="#{@tb_url}" />
</rdf:RDF>
-->
TBRDF
end

#alias :comment_new_tb_backup :comment_new
#def comment_new
#   cgi = @options['tb.cgi'] || './tb.rb'
#   url = "#{cgi}/#{@tb_date.strftime( '%Y%m%d' )}"
#   %Q|#{comment_new_tb_backup }</a>] [<a href="#{url}">TrackBack|
#end
 
#
# hide TrackBacks in TSUKKOMI
#
eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class Comment
		def visible_true?
			@show
		end
		def visible?
			@show and /^(Track|Ping)Back$/ !~ name
		end
	end
end
MODIFY_CLASS
 
#
# insert TrackBacks above Today's Link.
#
alias :referer_of_today_short_tb_backup :referer_of_today_short
def referer_of_today_short( diary, limit )
	r = referer_of_today_short_tb_backup( diary, limit )
	if diary then
		count = 0
		diary.each_comment( 100 ) do |com, idx|
			next unless com.visible_true?
			count += 1 if /^(Track|Ping)Back$/ =~ com.name
		end
		r << %Q|<a href="#{@index}#{anchor @tb_date.strftime( '%Y%m%d' )}#t">TrackBacks(#{count})</a>| if count > 0
	end
	r
end
 
alias :referer_of_today_long_tb_backup :referer_of_today_long
def referer_of_today_long( diary, limit )
	r = ''
	if diary then
		r << %Q[<div class="caption"><a name="t">TrackBacks</a></div>\n]
		r << "<ul>\n"
		diary.each_comment( 100 ) do |com, idx|
			next unless com.visible_true?
			next unless /^(Track|Ping)Back$/ =~ com.name
			url, blog_name, title, excerpt = com.body.split(/\n/, 4)

			blog_name ||= ''
			title ||= ''
			excerpt ||= ''

			a = blog_name
			a += ':' + title unless title == ''
			a = url if a == ''

			r << %Q|<li><a href="#{url}">#{a}</a><br>|
			r << excerpt.gsub(/\n/, '<br>').gsub(/<br><br>\Z/,'') unless excerpt == ""
			r << %Q|</li>\n|
		end
		r << "</ul>\n"
	end
	r << referer_of_today_long_tb_backup( diary, limit )
end
