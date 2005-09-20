#!/usr/bin/env ruby

# amazonimg.rb $Revision: 1.4 $: CGI script for tDiary amazon plugin in secure mode.
#
# set URL of this script to @options['amazon.secure-cgi'] into tdiary.conf.
#
# Copyright (C) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

### modify settings below ###
@cache_path = 'SPECIFY YOUR CACHE PATH'  # directory for saving cache files
@proxy = nil                             # URL of HTTP proxy server if you need
@amazon_aid = 'cshs-22'                  # Amazon Association ID
@amazon_url = 'http://www.amazon.co.jp/exec/obidos/ASIN'
                                         # URL of items in amazon
@amazon_ecs_url = 'http://webservices.amazon.co.jp/onca/xml'
                                         # URL of Amazon ECS service
#############################

#--- for test settings ---
#@cache_path = '/tmp/amazon_test_cache'
#@proxy = 'http://localhost:10080'
#-------------------------

### do not change these variables ###
@amazon_subscription_id = '1CVA98NEF1G753PFESR2'
@amazon_require_version = '2005-07-26'
#####################################

require 'cgi'
require 'open-uri'
require 'timeout'
require 'rexml/document'
require 'nkf'

def amazon_call_ecs( asin )
	aid = @amazon_aid || 'cshs-22'

	url =  @amazon_ecs_url.dup
	url << "?Service=AWSECommerceService"
	url << "&SubscriptionId=#{@amazon_subscription_id}"
	url << "&AssociateTag=#{aid}"
	url << "&Operation=ItemLookup"
	url << "&ItemId=#{asin}"
	url << "&ResponseGroup=Medium"
	url << "&Version=#{@amazon_require_version}"

	timeout( 10 ) do
		open( url, :proxy => @proxy ) {|f| f.read}
	end
end

def amazon_redirect( cgi, asin, size )
	begin
		xml = File::read( "#{@cache_path}/#{asin}.xml" )
	rescue Errno::ENOENT
		xml =  amazon_call_ecs( asin )
		Dir::mkdir( @cache_path ) unless File::directory?( @cache_path )
		File::open( "#{@cache_path}/#{asin}.xml", 'wb' ) {|f| f.write( xml )}
	end
	doc = REXML::Document::new( xml ).root
	item = doc.elements.to_a( '*/Item' )[0]
	s = case size
		when 0; 'Large'
		when 2; 'Small'
		else  ; 'Medium'
	end
	begin
		img_url = item.elements.to_a( "#{s}Image/URL" )[0].text
	rescue
		img_url = "http://www.tdiary.org/images/amazondefaults/#{s.downcase}.png"
	end
	print cgi.header( {'Location' => img_url} )
end

cgi = CGI::new
asin, = cgi.params['asin']
size, = cgi.params['size']
if asin && /[0-9A-Z]{10}/ =~ asin then
	size = '1' if !size or size.length == 0
	amazon_redirect( cgi, asin.untaint, size.to_i )
else
	puts "Content-Type: text/plain\n\nBAD REQUEST\nasin:#{asin}\nsize:#{size}"
end
