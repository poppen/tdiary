# output_rdf.rb: tDiary plugin to generate RDF file when diary updated.
# $Revision: 1.20 $
#
# See document to @lang/output_rdf.rb
#
# Copyright (c) 2003 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
# Distributed under the GPL
#

add_header_proc {
  fname = @options['output_rdf.file'] || 'index.rdf'
  %Q'\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{File::basename( fname )}">\n'
}

if ( /^(append|replace|trackbackreceive)$/ =~ @mode ) || ( /^comment$/ =~ @mode and @comment ) then
	date = @date.strftime("%Y%m%d")
	diary = @diaries[date]
	uri = "#{@conf.base_url}#{@conf.index}".gsub(%r|/\./|, '/')
	rdf_file = @options['output_rdf.file'] || 'index.rdf'
	rdf_channel_about = "#{@conf.base_url}#{File::basename( rdf_file )}"
	r = ""
	r <<<<-RDF
<?xml version="1.0" encoding="#{@output_rdf_encode}"?>
<rdf:RDF 
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns="http://purl.org/rss/1.0/"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xml:lang="#{@conf.html_lang}"
>
 <channel rdf:about="#{rdf_channel_about}">
   <title>#{CGI::escapeHTML( @html_title )}</title>
   <link>#{uri}</link>
   <description>#{CGI::escapeHTML( @html_title )}</description>
   <dc:date>#{Time.now.strftime('%Y-%m-%dT%H:%M')}</dc:date>
	RDF

	rdf_image = @options['output_rdf.image']
	r << %Q[<image rdf:resource="#{rdf_image}" />\n] if rdf_image

	r <<<<-RDF
	<items>
     <rdf:Seq>
	RDF
	idx = 1
 	diary.visible? and diary.each_section do |section|
		if section.subtitle then
		r <<<<-RDF
       <rdf:li rdf:resource="#{uri}#{anchor "#{date}\#p#{'%02d' % idx}"}" />
 		RDF
		end
  		idx += 1
	end

	comment_link = ""
	if diary.visible? and diary.count_comments > 0 then
  		diary.each_visible_comment( 100 ) do |comment,idx|
			comment_link = %Q[#{uri}#{anchor "#{date}\#c#{'%02d' % idx}"}]
			r <<<<-RDF
       <rdf:li rdf:resource="#{comment_link}" />
			RDF
		end
 	end
	r <<<<-RDF
     </rdf:Seq>
   </items>
 </channel>
	RDF

	if rdf_image
		r << %Q[<image rdf:abount="#{rdf_image}">\n]
		r << %Q[<title>#{@conf.html_title}</title>\n]
		r << %Q[<url>#{rdf_image}</url>\n]
		r << %Q[<link>#{path}</link>\n]
		r << %Q[</image>\n]
	end

	idx = 1
 	diary.visible? and diary.each_section do |section|
		if section.subtitle then
		link = %Q[#{uri}#{anchor "#{date}\#p#{'%02d' % idx}"}]
		subtitle = section.subtitle_to_html
		desc = section.body_to_html
		old_apply_plugin = @options['apply_plugin']
		@options['apply_plugin'] = true
		subtitle = apply_plugin(subtitle, true).strip
		desc = apply_plugin(desc, true).strip
		@options['apply_plugin'] = old_apply_plugin
		desc = @conf.shorten( desc )
		r <<<<-RDF
 <item rdf:about="#{link}">
   <title>#{CGI::escapeHTML( subtitle )}</title>
   <link>#{link}</link>
   <description>#{CGI::escapeHTML( desc )}</description>
 </item>
 		RDF
		end
  		idx += 1
	end
	if diary.visible? and diary.count_comments > 0 then
  		diary.each_visible_comment( 100 ) do |comment,idx|
			link = "#{uri}#{anchor "#{date}\#c#{'%02d' % idx}"}"	
		r <<<<-RDF
 <item rdf:about="#{link}">
   <title>#{comment_today}-#{idx} (#{CGI::escapeHTML( comment.name )})</title>
   <link>#{link}</link>
   <description>#{CGI::escapeHTML( @conf.shorten( comment.body ) )}</description>
   <dc:date>#{comment.date.strftime('%Y-%m-%dT%H:%M')}</dc:date>
 </item>
			RDF
		end
 	end
	r << "</rdf:RDF>"
	r = @output_rdf_encoder.call( r )
	mtime = File::mtime( rdf_file )
	File::open( rdf_file, 'w' ) do |o|
		o.puts r
	end
	begin
		File::utime( mtime, mtime, rdf_file ) unless diary.visible?
	rescue
	end
end
