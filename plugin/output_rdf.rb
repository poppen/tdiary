# output_rdf.rb: tDiary plugin to generate RDF file when diary updated.
# $Revision: 1.15 $
#
# See document to @lang/output_rdf.rb
#
# Copyright (c) 2003 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
# Distributed under the GPL
#

add_header_proc {
  fname = @options['output_rdf.file'] || 'index.rdf'
  %Q'\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{fname}">\n'
}

if ( /^(append|replace|trackbackreceive)$/ =~ @mode ) || ( /^comment$/ =~ @mode and @comment ) then
	date = @date.strftime("%Y%m%d")
	diary = @diaries[date]
	host = ENV['HTTP_HOST'] 
	path = ENV['REQUEST_URI']
	path = path[0..path.rindex( "/" )]
	uri = "#{host}#{path}#{@index}".gsub( /\/\.?\//, '/' )
	rdf_file = @options['output_rdf.file'] || 'index.rdf'
	rdf_channel_about = "#{host}#{path}#{rdf_file}"
	r = ""
	r <<<<-RDF
<?xml version="1.0" encoding="#{@output_rdf_encode}"?>
<rdf:RDF 
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns="http://purl.org/rss/1.0/"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xml:lang="#{@conf.html_lang}"
>
 <channel rdf:about="http://#{rdf_channel_about}">
   <title>#{@html_title}</title>
   <link>http://#{uri}</link>
   <description>#{@html_title}</description>
   <dc:date>#{Time.now.strftime('%Y-%m-%dT%H:%M')}</dc:date>
   <items>
     <rdf:Seq>
	RDF
	idx = 1
 	diary.each_section do |section|
		if section.subtitle then
		r <<<<-RDF
       <rdf:li rdf:resource="http://#{uri}#{anchor "#{date}\#p#{'%02d' % idx}"}" />
 		RDF
		end
  		idx += 1
	end

	comment_link = ""
	if diary.count_comments > 0 then
  		diary.each_visible_comment( 100 ) do |comment,idx|
			comment_link = %Q[http://#{uri}#{anchor "#{date}\#c#{'%02d' % idx}"}]
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
 	idx = 1
 	diary.each_section do |section|
		if section.subtitle then
		link = %Q[http://#{uri}#{anchor "#{date}\#p#{'%02d' % idx}"}]
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
	if diary.count_comments > 0 then
  		diary.each_visible_comment( 100 ) do |comment,idx|
			link = "http://#{uri}#{anchor "#{date}\#c#{'%02d' % idx}"}"	
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
	File::open( rdf_file, 'w' ) do |o|
		o.puts r
	end
end
