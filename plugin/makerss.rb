# makerss.rb: $Revision: 1.8 $
#
# generate RSS file when updating.
#
# options:
#   @options['makerss.file']  : local file name of RSS file. default: 'index.rdf'.
#   @options['makerss.url']   : URL of RSS file.
#   @options['makerss.image'] : URL of site banner image.
#
#   CAUTION: Before using, make 'index.rdf' file into the directory of your diary,
#            and permit writable to httpd.
#
# Copyright (c) 2004 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
if /^append|replace|comment|showcomment|trackbackreceive$/ =~ @mode then
	eval( <<-TOPLEVEL_CLASS, TOPLEVEL_BINDING )
		module TDiary
			class RDFSection
				attr_reader :id, :time, :section

				# 'id' has 'YYYYMMDDpNN' format (p or c).
				# 'time' is Last-Modified this section as a Time object.
				def initialize( id, time, section )
					@id, @time, @section = id, time, section
				end
		
				def time_string
					g = @time.dup.gmtime
					l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
					tz = (g.to_i - l.to_i)
					zone = sprintf( "%+03d:%02d", tz / 3600, tz % 3600 / 60 )
					@time.strftime( "%Y-%m-%dT%H:%M:%S" ) + zone
				end

				def <=>( other )
					other.time <=> @time
				end
			end
		end
	TOPLEVEL_CLASS
end

def makerss_update
	date = @date.strftime( "%Y%m%d" )
	diary = @diaries[date]

	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	uri.gsub!( %r|/\./|, '/' )

	require 'pstore'
	cache = {}
	xml = ''
	seq = ''
	body = ''
	PStore::new( "#{@cache_path}/makerss.cache" ).transaction do |db|
		begin
			cache = db['cache'] if db.root?( 'cache' )
	
			if /^append|replace$/ =~ @mode then
				index = 0
				diary.each_section do |section|
					index += 1
					id = "#{date}p%02d" % index
					if diary.visible? and !cache[id] then
						cache[id] = RDFSection::new( id, Time::now, section )
					elsif !diary.visible? and cache[id]
						cache.delete( id )
					elsif diary.visible? and cache[id]
						if cache[id].section.body_to_html != section.body_to_html then
							cache[id] = RDFSection::new( id, Time::now, section )
						end
					end
				end
			elsif /^comment$/ =~ @mode
				id = "#{date}c%02d" % diary.count_comments
				cache[id] = RDFSection::new( id, @comment.date, @comment )
			elsif /^showcomment$/ =~ @mode
				index = 0
				diary.each_comment( 100 ) do |comment|
					index += 1
					id = "#{date}c%02d" % index
					if !cache[id] and comment.visible? then
						cache[id] = RDFSection::new( id, comment.date, comment )
					elsif cache[id] and !comment.visible?
						cache.delete( id )
					end
				end
			end
	
			xml << makerss_header( uri )
			seq << "<items><rdf:Seq>\n"
			cache.values.sort{|a,b| b.time <=> a.time}.each_with_index do |rdfsec, idx|
				if idx < 15 then
					seq << makerss_seq( uri, rdfsec )
					body << makerss_body( uri, rdfsec )
				elsif idx > 50
					cache.delete( rdfsec.id )
				end
			end
	
			db['cache'] = cache
		rescue PStore::Error
		end
	end

	rdf_image = @options['makerss.image']
	xml << %Q[<image rdf:resource="#{rdf_image}" />\n] if rdf_image

	xml << seq << "</rdf:Seq></items>\n</channel>\n"
	xml << makerss_image( uri, rdf_image ) if rdf_image
	xml << body
	xml << makerss_footer
	rdf_file = @options['makerss.file'] || 'index.rdf'
	rdf_file = 'index.rdf' if rdf_file.length == 0
	File::open( rdf_file, 'w' ) do |f|
		f.write( @makerss_encoder.call( xml ) )
	end
end

def makerss_header( uri )
	rdf_url = @options['makerss.url'] || "#{@conf.base_url}index.rdf"
	rdf_url = "#{@conf.base_url}index.rdf" if rdf_url.length == 0

	desc = @options['whatsnew_list.rdf.description'] || @conf.html_title

	xml = %Q[<?xml version="1.0" encoding="#{@makerss_encode}"?>
<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xml:lang="#{@conf.html_lang}">
	<channel rdf:about="#{rdf_url}">
	<title>#{CGI::escapeHTML( @conf.html_title )}</title>
	<link>#{uri}</link>
	<description>#{CGI::escapeHTML( desc )}</description>
	<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>
	]
end

def makerss_seq( uri, rdfsec )
	%Q|<rdf:li rdf:resource="#{uri}#{anchor rdfsec.id}"/>\n|
end

def makerss_image( uri, rdf_image )
	%Q[<image rdf:about="#{rdf_image}">
	<title>#{@conf.html_title}</title>
	<url>#{rdf_image}</url>
	<link>#{uri}</link>
	</image>
	]
end

def makerss_body( uri, rdfsec )
	rdf = %Q|<item rdf:about="#{uri}#{anchor rdfsec.id}">\n|
	rdf << %Q|<link>#{uri}#{anchor rdfsec.id}</link>\n|
	rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
	if rdfsec.section.respond_to?( :body_to_html ) then
		a = rdfsec.id.scan( /(\d{4})(\d\d)(\d\d)/ ).flatten.map{|s| s.to_i}
		date = Time::local( *a )
		old_apply_plugin = @options['apply_plugin']
		@options['apply_plugin'] = true
		body_enter_proc( date )
		subtitle = apply_plugin( rdfsec.section.subtitle_to_html, true ).strip
		desc = subtitle + apply_plugin( rdfsec.section.body_to_html ).strip
		body_leave_proc( date )
		@options['apply_plugin'] = old_apply_plugin
		rdf << %Q|<title>#{subtitle}</title>\n|
		rdf << %Q|<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>\n|
		rdf << %Q|<content:encoded><![CDATA[#{desc}]]></content:encoded>\n|
	else # TSUKKOMI
		rdf << %Q|<title>#{makerss_tsukkomi_label( rdfsec.id )} (#{CGI::escapeHTML( rdfsec.section.name )})</title>\n|
		rdf << %Q|<dc:creator>#{CGI::escapeHTML( rdfsec.section.name )}</dc:creator>\n|
		rdf << %Q|<content:encoded><![CDATA[#{CGI::escapeHTML( rdfsec.section.body ).gsub( /\n/, '<br>' )}]]></content:encoded>\n|
	end
	rdf << "</item>\n"
end

def makerss_footer
	"</rdf:RDF>\n"
end

add_update_proc do
	makerss_update
end

if /^showcomment$/ =~ @mode then
	makerss_update
end

add_header_proc {
	rdf_url = @options['makerss.url'] || "#{@conf.base_url}index.rdf"
	rdf_url = "#{@conf.base_url}index.rdf" if rdf_url.length == 0
	%Q|\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{rdf_url}">\n|
}
