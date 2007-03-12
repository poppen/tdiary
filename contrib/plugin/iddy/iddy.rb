#
# iddy.rb: iddy.jp plugin for tDiary
#
# Copyright (C) 2007 by TADA Tadashi <sho@spc.gr.jp>
# Distributed under GPL.
#
require 'open-uri'
require 'timeout'
require 'rexml/document'

def iddy( id, key )
	begin
		cache = "#{@cache_path}/iddy.xml"
		xml = open( cache ) {|f| f.read }
		if Time::now > File::mtime( cache ) + 60*60 then
			File::delete( cache )  # clear cache 1 hour later
		end
	rescue Errno::ENOENT
		begin
			xml = iddy_call_api( id, key )
			open( cache, 'wb' ) {|f| f.write( xml ) }
		rescue Timeout::Error
			return '<div class="iddy error">No Profile.</div>'
		end
	end

	doc = REXML::Document::new( xml )
	if doc.elements[1].attribute( 'status' ).to_s == 'fail' then
		return '<div class="iddy error">idd.jp returns fail.</div>'
	end

	user = doc.elements.to_a( '*/*/user' )[0].elements
	
	html = '<div class="iddy">'
	html << %Q|<a href="#{user.to_a( 'profileurl' )[0].text}">|
	html << %Q|<span class="iddy-image"><img src="#{user.to_a( 'imageurl' )[0].text}" alt="image" width="96" height="96"></span>|
	html << %Q|<span class="iddy-name">#{user.to_a( 'name' )[0].text}</span>|
	html << '</a>'
	html << %Q|<span class="iddy-powered">Powerd by <a href="http://iddy.jp/">iddy.jp</a></span>|
	html << '</div>'
	@conf.to_native( html )
end

def iddy_call_api( id, key )
	request = "http://iddy.jp/api/user/?apikey=#{key}"
	request << "&accountname=#{id}"

	proxy = @conf['proxy']
	proxy = 'http://' + proxy if proxy
	timeout( 10 ) do
		open( request, :proxy => proxy ) {|f| f.read }
	end
end
