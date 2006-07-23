# makerss.rb: $Revision: 1.44 $
#
# generate RSS file when updating.
#
# options configurable through settings:
#   @conf['makerss.hidecontent'] : hide full-text content. default: false
#   @conf['makerss.shortdesc'] : shorter description. default: false
#   @conf['makerss.comment_link'] : insert tsukkomi's link. default: false
#
# options to be edited in tdiary.conf:
#   @conf['makerss.file']  : local file name of RSS file. default: 'index.rdf'.
#   @conf['makerss.url']   : URL of RSS file.
#   @conf['makerss.no_comments.file']  : local file name of RSS file without
#                            comments. default: 'no_comments.rdf'.
#   @conf['makerss.no_comments.url']   : URL of RSS file without TSUKOMI.
#   @conf.banner           : URL of site banner image (can be relative)
#   @conf.description      : desciption of the diary
#   @conf['makerss.partial'] : how much portion of body to be in description
#                            used when makerss.shortdesc, default: 0.25
#
#   CAUTION: Before using, make 'index.rdf' and 'no_comments.rdf' file
#            into the directory of your diary, and permit writable to httpd.
#
# Copyright (c) 2004 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#

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

@makerss_rsses = @makerss_rsses || []

class MakeRssFull
	def initialize( conf )
		@conf = conf
		@item_num = 0
	end

	def title
		''
	end

	def head( str )
		@head = str
		@head.sub!( /<\/title>/, "#{title}</title>" )
	end

	def foot( str ); @foot = str; end
	def image( str ); @image = str; end
	def banner( str ); @banner = str; end

	def item( seq, body, rdfsec )
		@item_num += 1
		return if @item_num > 15
		@seq = '' unless @seq
		@seq << seq
		@body = '' unless @body
		@body << body
	end

	def xml
		xml = @head.to_s
		xml << @image.to_s
		xml << "<items><rdf:Seq>\n"
		xml << @seq.to_s
		xml << "</rdf:Seq></items>\n</channel>\n"
		xml << @banner.to_s
		xml << @body.to_s
		xml << @foot.to_s
		xml.gsub( /[\x00-\x1f]/e ){|s| s =~ /[\r\n\t]/ ? s : ""}
	end

	def file
		f = @conf['makerss.file'] || 'index.rdf'
		f = 'index.rdf' if f.length == 0
		f
	end

	def writable?
		if FileTest::writable?( file ) then
			return true
		elsif FileTest::exist?( file )
			return false
		else # try to create
			begin
				File::open( file, 'w' ){|f|}
				return true
			rescue
				return false
			end
		end
	end

	def write( encoder )
		begin
			File::open( file, 'w' ) do |f|
				f.write( encoder.call( xml ) )
			end
		rescue
		end
	end

	def url
		u = @conf['makerss.url'] || "#{@conf.base_url}index.rdf"
		u = "#{@conf.base_url}index.rdf" if u.length == 0
		u
	end
end

@makerss_rsses << MakeRssFull::new( @conf )

class MakeRssNoComments < MakeRssFull
	def title
		'(without comments)'
	end

	def item( seq, body, rdfsec )
		return unless rdfsec.section.respond_to?( :body_to_html )
		super
	end

	def file
		f = @conf['makerss.no_comments.file'] || 'no_comments.rdf'
		f = 'no_comments.rdf' if f.length == 0
		f
	end

	def write( encoder )
		return unless @conf['makerss.no_comments']
		super( encoder )
	end

	def url
		return nil unless @conf['makerss.no_comments']
		u = @conf['makerss.no_comments.url'] || "#{@conf.base_url}no_comments.rdf"
		u = "#{@conf.base_url}no_comments.rdf" if u.length == 0
		u
	end
end

@makerss_rsses << MakeRssNoComments::new( @conf )

def makerss_update
	date = @date.strftime( "%Y%m%d" )
	diary = @diaries[date]

	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	uri.gsub!( %r|/\./|, '/' )

	require 'pstore'
	cache = {}
	rsses = @makerss_rsses

	begin
		PStore::new( "#{@cache_path}/makerss.cache" ).transaction do |db|
			begin
				cache = db['cache'] if db.root?( 'cache' )

				if /^append|replace$/ =~ @mode then
					format = "#{date}p%02d"
					index = 0
					diary.each_section do |section|
						index += 1
						id = format % index
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

					loop do
						index += 1
						id = format % index
						if cache[id] then
							cache.delete( id )
						else
							break
						end
					end
				elsif /^comment$/ =~ @mode and @conf.show_comment
					id = "#{date}c%02d" % diary.count_comments( true )
					cache[id] = RDFSection::new( id, @comment.date, @comment )
				elsif /^showcomment$/ =~ @mode
					index = 0
					diary.each_comment do |comment|
						index += 1
						id = "#{date}c%02d" % index
						if !cache[id] and (@conf.show_comment and comment.visible? and /^(TrackBack|Pingback)$/i !~ comment.name) then
							cache[id] = RDFSection::new( id, comment.date, comment )
						elsif cache[id] and !(@conf.show_comment and comment.visible? and /^(TrackBack|Pingback)$/i !~ comment.name)
							cache.delete( id )
						end
					end
				end

				rsses.each{|rss| rss.head( makerss_header( uri ) ) }
				cache.values.sort{|a,b| b.time <=> a.time}.each_with_index do |rdfsec, idx|
					unless rdfsec.section.respond_to?( :visible? ) and !rdfsec.section.visible?
						rsses.each {|rss|
							rss.item( makerss_seq( uri, rdfsec ), makerss_body( uri, rdfsec ), rdfsec )
						}
					end
					if idx > 50
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

	if @conf.banner and not @conf.banner.empty?
		if /^http/ =~ @conf.banner
			rdf_image = @conf.banner
		else
			rdf_image = @conf.base_url + @conf.banner
		end
		rsses.each {|r| r.image( %Q[<image rdf:resource="#{rdf_image}" />\n] ) }
	end

	rsses.each {|r|
		r.banner( makerss_banner( uri, rdf_image ) ) if rdf_image
		r.foot( makerss_footer )
		r.write( @makerss_encoder )
	}

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
<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xml:lang="#{@conf.html_lang}">
	<channel rdf:about="#{rdf_url}">
	<title>#{CGI::escapeHTML( @conf.html_title )}</title>
	<link>#{uri}</link>
	<xhtml:link xhtml:rel="alternate" xhtml:media="handheld" xhtml:type="text/html" xhtml:href="#{uri}" />
	<description>#{desc ? CGI::escapeHTML( desc ) : ''}</description>
	<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>
	<dc:rights>#{CGI::escapeHTML( copyright )}</dc:rights>
	]
end

def makerss_seq( uri, rdfsec )
	%Q|<rdf:li rdf:resource="#{uri}#{anchor rdfsec.id}"/>\n|
end

def makerss_banner( uri, rdf_image )
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
		rdf << %Q|<xhtml:link xhtml:rel="alternate" xhtml:media="handheld" xhtml:type="text/html" xhtml:href="#{uri}#{anchor rdfsec.id}" />\n|
		rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
		a = rdfsec.id.scan( /(\d{4})(\d\d)(\d\d)/ ).flatten.map{|s| s.to_i}
		date = Time::local( *a )
		body_enter_proc( date )
		old_apply_plugin = @conf['apply_plugin']
		@conf['apply_plugin'] = true

		subtitle = apply_plugin( rdfsec.section.subtitle_to_html, true ).strip
		subtitle.sub!( /^(\[([^\]]+)\])+ */, '' )
		if subtitle.empty?
			subtitle = apply_plugin( rdfsec.section.body_to_html, true ).strip
			subtitle = @conf.shorten( subtitle.gsub( /&.*?;/, '' ), 20 )
		end
		rdf << %Q|<title>#{CGI::escapeHTML( subtitle )}</title>\n|
		rdf << %Q|<dc:creator>#{CGI::escapeHTML( @conf.author_name )}</dc:creator>\n|
		unless rdfsec.section.categories.empty?
			rdfsec.section.categories.each do |category|
				rdf << %Q|<dc:subject>#{CGI::escapeHTML( category )}</dc:subject>\n|
			end
		end
		desc = apply_plugin( rdfsec.section.body_to_html, true ).strip
		desc.gsub!( /&.*?;/, '' )
		rdf << %Q|<description>#{CGI::escapeHTML( makerss_desc_shorten( desc ) )}</description>\n|
		unless @conf['makerss.hidecontent']
			text = ''
			text += '<h3>' + apply_plugin( rdfsec.section.subtitle_to_html.sub( /^(\[([^\]]+)\])+ */, '' ) ).strip + '</h3>' if rdfsec.section.subtitle_to_html and not rdfsec.section.subtitle_to_html.empty?
			text += apply_plugin( rdfsec.section.body_to_html ).strip
			unless text.empty?
				text.gsub!( /\]\]>/, ']]&gt;' )
				rdf << %Q|<content:encoded><![CDATA[#{text}|
            unless @conf['makerss.comment_link']
               ymd = date.strftime( "%Y%m%d" )
               uri = @conf.index.dup
               uri[0, 0] = @conf.base_url unless %r|^https?://|i =~ uri
               uri.gsub!( %r|/\./|, '/' )
               rdf << %Q|\n<p><a href="#{uri + anchor( "#{ymd}c" )}">#{ comment_new }</a></p>|
            end
            rdf << %Q|]]></content:encoded>\n|
			end
		end

		body_leave_proc( date )
		@conf['apply_plugin'] = old_apply_plugin
		rdf << "</item>\n"
	else # TSUKKOMI
		rdf = %Q|<item rdf:about="#{uri}#{anchor rdfsec.id}">\n|
		rdf << %Q|<link>#{uri}#{anchor rdfsec.id}</link>\n|
		rdf << %Q|<dc:date>#{rdfsec.time_string}</dc:date>\n|
		rdf << %Q|<title>#{makerss_tsukkomi_label( rdfsec.id )} (#{CGI::escapeHTML( rdfsec.section.name )})</title>\n|
		rdf << %Q|<dc:creator>#{CGI::escapeHTML( rdfsec.section.name )}</dc:creator>\n|
		text = rdfsec.section.body
		rdf << %Q|<description>#{CGI::escapeHTML( makerss_desc_shorten( text ) )}</description>\n|
		unless @conf['makerss.hidecontent']
			rdf << %Q|<content:encoded><![CDATA[#{text.make_link.gsub( /\n/, '<br>' ).gsub( /<br><br>\Z/, '' ).gsub( /\]\]>/, ']]&gt;' )}]]></content:encoded>\n|
		end
		rdf << "</item>\n"
	end
	rdf
end

def makerss_footer
	"</rdf:RDF>\n"
end

add_update_proc do
	makerss_update unless @cgi.params['makerss_update'][0] == 'false'
end

add_header_proc {
	html = ''
	@makerss_rsses.each do |rss|
		next unless rss.url
		html << %Q|\t<link rel="alternate" type="application/rss+xml" title="RSS#{rss.title}" href="#{rss.url}">\n|
	end
	html
}

add_conf_proc( 'makerss', @makerss_conf_label, 'update' ) do
	if @mode == 'saveconf' then
		%w( hidecontent shortdesc comment_link no_comments).each do |s|
			item = "makerss.#{s}"
			@conf[item] = ( 't' == @cgi.params[item][0] )
		end
	end

	@makerss_rsses.each do |rss|
		if rss.class == MakeRssFull then
			@makerss_full = rss
		elsif rss.class == MakeRssNoComments
			@makerss_no_comments = rss
		end
	end
	makerss_conf_html
end

add_edit_proc do
	checked = @cgi.params['makerss_update'][0] == 'false' ? ' checked' : ''
	r = <<-HTML
	<div class="makerss">
	<input type="checkbox" name="makerss_update" value="false"#{checked} tabindex="390" />
	#{@makerss_edit_label}
	</div>
	HTML
end
