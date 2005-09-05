# makerss.rb: $Revision: 1.29 $
#
# generate RSS file when updating.
#
# options configurable through settings:
#   @conf['makerss.hidecomment'] : hide tsukkomi's. default: false
#   @conf['makerss.hidecontent'] : hide full-text content. default: false
#   @conf['makerss.shortdesc'] : shorter description. default: false
#
# options to be edited in tdiary.conf:
#   @conf['makerss.file']  : local file name of RSS file. default: 'index.rdf'.
#   @conf['makerss.url']   : URL of RSS file.
#   @conf.icon             : URL of site icon image (can be relative)
#   @conf.description      : desciption of the diary
#   @conf['makerss.partial'] : how much portion of body to be in description
#                              used when makerss.shortdesc, default: 0.25
#
#   CAUTION: Before using, make 'index.rdf' file into the directory of your diary,
#            and permit writable to httpd.
#
# Copyright (c) 2004 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#

# backward compatibility
item = 'makerss.hidecomment'
if true == @conf[item] then
  @conf[item] = 'content'
end

if /^append|replace|comment|showcomment|trackbackreceive|pingbackreceive$/ =~ @mode then
	unless @conf.description
		@conf.description = @conf['whatsnew_list.rdf.description']
	end
	eval( <<-TOPLEVEL_CLASS, TOPLEVEL_BINDING )
		module TDiary
			class RDFSection
				attr_reader :id, :time, :section, :diary_title

				# 'id' has 'YYYYMMDDpNN' format (p or c).
				# 'time' is Last-Modified this section as a Time object.
				def initialize( id, time, section )
					@id, @time, @section, @diary_title = id, time, section, diary_title
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
	begin
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
							if cache[id].section.body_to_html != section.body_to_html or
									cache[id].section.subtitle_to_html != section.subtitle_to_html then
								cache[id] = RDFSection::new( id, Time::now, section )
							end
						end
					end
				elsif /^comment$/ =~ @mode and @conf.show_comment
					id = "#{date}c%02d" % diary.count_comments( true )
					cache[id] = RDFSection::new( id, @comment.date, @comment )
				elsif /^showcomment$/ =~ @mode
					index = 0
					diary.each_comment( 100 ) do |comment|
						index += 1
						id = "#{date}c%02d" % index
						if !cache[id] and (@conf.show_comment and comment.visible? and /^(TrackBack|Pingback)$/i !~ comment.name) then
							cache[id] = RDFSection::new( id, comment.date, comment )
						elsif cache[id] and !(@conf.show_comment and comment.visible? and /^(TrackBack|Pingback)$/i !~ comment.name)
							cache.delete( id )
						end
					end
				end

				xml << makerss_header( uri )
				seq << "<items><rdf:Seq>\n"
				item_max = 15
				cache.values.sort{|a,b| b.time <=> a.time}.each_with_index do |rdfsec, idx|
					if idx < item_max then
						if rdfsec.section.respond_to?( :visible? ) and !rdfsec.section.visible?
							item_max += 1
						else
							seq << makerss_seq( uri, rdfsec )
							body << makerss_body( uri, rdfsec )
						end
					elsif idx > 50
						cache.delete( rdfsec.id )
					end
				end

				db['cache'] = cache
			rescue PStore::Error
			end
		end
	rescue ArgumentError
		File.unlink( "#{@cache_path}/makerss.cache" )
		retry
	end

	if @conf.icon and not @conf.icon.empty?
		if /^http/ =~ @conf.icon
			rdf_image = @conf.icon
		else
			rdf_image = @conf.base_url + @conf.icon
		end
		xml << %Q[<image rdf:resource="#{rdf_image}" />\n]
	end

	xml << seq << "</rdf:Seq></items>\n</channel>\n"
	xml << makerss_image( uri, rdf_image ) if rdf_image
	xml << body
	xml << makerss_footer
	rdf_file = @conf['makerss.file'] || 'index.rdf'
	rdf_file = 'index.rdf' if rdf_file.length == 0
	File::open( rdf_file, 'w' ) do |f|
		f.write( @makerss_encoder.call( xml ) )
	end
end

def makerss_header( uri )
	rdf_url = @conf['makerss.url'] || "#{@conf.base_url}index.rdf"
	rdf_url = "#{@conf.base_url}index.rdf" if rdf_url.length == 0

	desc = @conf.description || ''

	copyright = Time::now.strftime( "Copyright %Y #{@conf.author_name}" )
	copyright += " <#{@conf.author_mail}>" if @conf.author_mail and not @conf.author_mail.empty?
	copyright += ", copyright of comments by respective authors"

	xml = %Q[<?xml version="1.0" encoding="#{@makerss_encode}"?>
<?xml-stylesheet href="rss.css" type="text/css"?>
<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xml:lang="#{@conf.html_lang}">
	<channel rdf:about="#{rdf_url}">
	<title>#{CGI::escapeHTML( @conf.html_title )}</title>
	<link>#{uri}</link>
	<description>#{desc ? CGI::escapeHTML( desc ) : ''}</description>
	<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>
	<dc:rights>#{CGI::escapeHTML( copyright )}</dc:rights>
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

def makerss_desc_shorten( text )
	if @conf['makerss.shortdesc'] then
		@conf['makerss.partial'] = 0.25 unless @conf['makerss.partial']
		len = ( text.size.to_f * @conf['makerss.partial'] ).ceil.to_i
		len = 500 if len > 500
	else
		len = 500
	end
	@conf.shorten( text, len )
end

def makerss_body( uri, rdfsec )
	rdf = ""
	if rdfsec.section.respond_to?( :body_to_html ) then
		rdf = %Q|<item rdf:about="#{uri}#{anchor rdfsec.id}">\n|
		rdf << %Q|<link>#{uri}#{anchor rdfsec.id}</link>\n|
		rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
		a = rdfsec.id.scan( /(\d{4})(\d\d)(\d\d)/ ).flatten.map{|s| s.to_i}
		date = Time::local( *a )
		body_enter_proc( date )
		old_apply_plugin = @conf['apply_plugin']
		@conf['apply_plugin'] = true

		subtitle = apply_plugin( rdfsec.section.subtitle_to_html, true ).strip
		if subtitle.empty?
			subtitle = apply_plugin( rdfsec.section.body_to_html, true ).strip
			subtitle = @conf.shorten( subtitle.gsub( /&.*?;/, '' ), 20 )
		end
		rdf << %Q|<title>#{CGI::escapeHTML( subtitle )}</title>\n|
		rdf << %Q|<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>\n|
		if ! rdfsec.section.categories.empty?
			rdfsec.section.categories.each do |category|
				rdf << %Q|<dc:subject>#{CGI::escapeHTML( category )}</dc:subject>\n|
			end
		end
		desc = apply_plugin( rdfsec.section.body_to_html, true ).strip
		desc.gsub!( /&.*?;/, '' )
		rdf << %Q|<description>#{CGI::escapeHTML( makerss_desc_shorten( desc ) )}</description>\n|
		unless @conf['makerss.hidecontent']
			text = ''
			text += '<h3>' + apply_plugin( rdfsec.section.subtitle_to_html ).strip + '</h3>' if rdfsec.section.subtitle_to_html and not rdfsec.section.subtitle_to_html.empty?
			text += apply_plugin( rdfsec.section.body_to_html ).strip
			unless text.empty?
				text.gsub!( /\]\]>/, ']]&gt;' )
				rdf << %Q|<content:encoded><![CDATA[#{text}]]></content:encoded>\n|
			end
		end

		body_leave_proc( date )
		@conf['apply_plugin'] = old_apply_plugin
		rdf << "</item>\n"
	else # TSUKKOMI
		unless 'any' == @conf['makerss.hidecomment'] then
			rdf = %Q|<item rdf:about="#{uri}#{anchor rdfsec.id}">\n|
			rdf << %Q|<link>#{uri}#{anchor rdfsec.id}</link>\n|
			rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
			rdf << %Q|<title>#{makerss_tsukkomi_label( rdfsec.id )} (#{CGI::escapeHTML( rdfsec.section.name )})</title>\n|
			rdf << %Q|<dc:creator>#{CGI::escapeHTML( rdfsec.section.name )}</dc:creator>\n|
			unless 'text' == @conf['makerss.hidecomment']
				text = rdfsec.section.body
				rdf << %Q|<description>#{CGI::escapeHTML( makerss_desc_shorten( text ) )}</description>\n|
				unless @conf['makerss.hidecontent']
					rdf << %Q|<content:encoded><![CDATA[#{text.make_link.gsub( /\n/, '<br>' ).gsub( /<br><br>\Z/, '' ).gsub( /\]\]>/, ']]&gt;' )}]]></content:encoded>\n|
				end
			end
			rdf << "</item>\n"
		end
	end
	rdf
end

def makerss_footer
	"</rdf:RDF>\n"
end

add_update_proc do
	makerss_update
end

add_header_proc {
	rdf_url = @conf['makerss.url'] || "#{@conf.base_url}index.rdf"
	rdf_url = "#{@conf.base_url}index.rdf" if rdf_url.length == 0
	%Q|\t<link rel="alternate" type="application/rss+xml" title="RSS" href="#{rdf_url}">\n|
}
