#!/usr/bin/env ruby
# tb.rb $Revision: 1.8 $
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
# derived from sheepman's tb.rb. Thanks to sheepman <sheepman@tcn.zaq.ne.jp>
# 

BEGIN { $defout.binmode }
$KCODE = 'n'

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift org_path.untaint
	require 'tdiary'
  
	@cgi = CGI::new
	conf = TDiary::Config::new
	tdiary = nil

	begin
		if /POST/i === @cgi.request_method and @cgi.valid?( 'url' )
			tdiary = TDiary::TDiaryTrackBackReceive::new( @cgi, 'day.rhtml', conf )
		elsif @cgi.valid?( '__mode') and @cgi.params['__mode'][0] == 'rss'
			tdiary = TDiary::TDiaryTrackBackRSS::new( @cgi, nil, conf )
		end
	rescue TDiary::TDiaryError
	end
	tdiary = TDiary::TDiaryTrackBackShow::new( @cgi, nil, conf ) unless tdiary

	head = {
		#'type' => 'application/xml',
		'type' => 'text/xml',
		'Vary' => 'User-Agent'
	}
	body = ''
	begin
		body = tdiary.eval_rhtml
		head['charset'] = conf.encoding
		head['Content-Length'] = body.size.to_s
		head['Pragma'] = 'no-cache'
		head['Cache-Control'] = 'no-cache'
		print @cgi.header( head )
		print body
	rescue TDiary::TDiaryTrackBackError
		head = {
			#'type' => 'application/xml',
			'type' => 'text/xml'
		}
		print @cgi.header( head )
		print TDiary::TDiaryTrackBackBase::fail_response($!.message)
	rescue TDiary::ForceRedirect
		head = {
			#'Location' => $!.path
			'type' => 'text/html',
		}
		head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
		print @cgi.header( head )
		print %Q[
			<html>
			<head>
			<meta http-equiv="refresh" content="0;url=#{$!.path}">
			<title>moving...</title>
			</head>
			<body>Wait or <a href="#{$!.path}">Click here!</a></body>
			</html>]
	end
rescue Exception
	puts "Content-Type: text/plain\n\n"
	puts "#$! (#{$!.class})"
	puts ""
	puts $@.join( "\n" )
end
# vim: ts=3
