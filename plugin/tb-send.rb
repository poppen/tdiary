# tb-send.rb $Revision: 1.14 $
#
# Copyright (c) 2003 Junichiro Kita <kita@kitaj.no-ip.com>
# You can distribute this file under the GPL.
#

add_edit_proc do |date|
	url = @cgi.params['plugin_tb_url'][0] || ''
	excerpt = @cgi.params['plugin_tb_excerpt'][0] || ''
	section = @cgi.params['plugin_tb_section'][0] || ''
	select_sections = ''
	unless @conf['tb.no_section'] then
		section_titles = ''
	 	idx = 1
		diary = @diaries[@date.strftime('%Y%m%d')]
		if diary then
			diary.each_section do |t|
				anc = 'p%02d' % idx
				selected = (section == anc ) ? ' selected' : ''
				section_titles << %[<option value="#{anc}"#{selected}>#{CGI::escapeHTML( apply_plugin( t.subtitle_to_html, true ) ).chomp}</option>\n\t\t\t]
				idx += 1
			end
		end
		anc = 'p%02d' % idx
		section_titles << %[<option value="#{anc}"#{(section == anc ) ? ' selected' : ''}>#{@tb_send_label_current_section}</option>]
	
		select_sections = <<-FROM
			<div class="field">
			#{@tb_send_label_section}: <select name="plugin_tb_section" tabindex="501">
			<option value="">#{@tb_send_label_no_section}</option>
			#{section_titles}
			</select>
			</div>
		FROM
	end

	<<-FORM
		<h3 class="subtitle">TrackBack</h3>
		<div class="trackback">
			<div class="field title">
			#{@tb_send_label_url}: <textarea tabindex="500" style="height: 1em;" name="plugin_tb_url" cols="40" rows="1">#{CGI::escapeHTML( url )}</textarea>
			</div>
			#{select_sections}
			<div class="textarea">
			#{@tb_send_label_excerpt}: <textarea tabindex="502" style="height: 4em;" name="plugin_tb_excerpt" cols="70" rows="4">#{CGI::escapeHTML( excerpt )}</textarea>
			</div>
		</div>
	FORM
end

add_update_proc do
	tb_send_trackback if /^(append|replace)$/ =~ @mode
end

def tb_send_trackback
	urls = @cgi.params['plugin_tb_url'][0] || ''
	title = @cgi.params['title'][0]
	excerpt = @cgi.params['plugin_tb_excerpt'][0]
	section = @cgi.params['plugin_tb_section'][0]
	blog_name = @conf.html_title

	date = @date.strftime( '%Y%m%d' )
	if section && !section.empty? then
		diary = @diaries[date]
		ary = []; diary.each_section{|s| ary << s}
		section = sprintf( 'p%02d', ary.length ) if @mode == 'append'
		num = section[1..-1].to_i - 1
		if num < ary.size
			title = ary[num].subtitle_to_html if ary[num].subtitle && !ary[num].subtitle.empty?
			excerpt = ary[num].body_to_html if excerpt.empty?
		end
	end

	if !excerpt || excerpt.empty?
		excerpt = @diaries[date].to_html({})
	end

	old_apply_plugin = @options['apply_plugin']
	@options['apply_plugin'] = true
	title = apply_plugin( title, true )
	excerpt = apply_plugin( excerpt, true )
	@options['apply_plugin'] = old_apply_plugin

	#if excerpt.length >= 255 then
	#	excerpt = @conf.shorten( excerpt.gsub( /\r/, '' ).gsub( /\n/, "\001" ), 252 ).gsub( /\001/, "\n" )
	#end

	my_url = %Q|#{@conf.index}#{anchor(@date.strftime('%Y%m%d'))}|
	my_url[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	my_url += "##{section}" if section && !section.empty?
	my_url.gsub!( %r|/\./|, '/' )
 
	require 'net/http'
	urls.split.each do |url|
		trackback = "url=#{CGI::escape(my_url)}"
		trackback << "&charset=#{@tb_send_ping_charset}"
		trackback << "&title=#{CGI::escape( @conf.to_native( title ) )}" unless title.empty?
		trackback << "&excerpt=#{CGI::escape( @conf.to_native( excerpt) )}" unless excerpt.empty?
		trackback << "&blog_name=#{CGI::escape(blog_name)}"

		if %r|^http://([^/]+)(/.*)$| =~ url then
			request = $2
			host, port = $1.split( /:/, 2 )
			port = '80' unless port
			Net::HTTP.version_1_1
			begin
				Net::HTTP.start( host.untaint, port.to_i ) do |http|
					response, = http.post( request, trackback,
						"Content-Type" => 'application/x-www-form-urlencoded')
					
					error, = response.body.scan(%r|<error>(\d)</error>|)[0]
					if error == '1'
						reason, = response.body.scan(%r|<message>(.*)</message>|m)[0]
						raise TDiaryTrackBackError.new(reason) if urls.length == 1
					end
				end
			rescue
				raise TDiaryTrackBackError.new( "when sending TrackBack Ping: #{$!.message}" ) if urls.length == 1
			end
		end
	end
end

# vim: ts=3
