#!/usr/bin/env ruby

# weather_index.rb $Revision$
#
# Copyright (C) 2006 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

require 'cgi'
require 'time'
require 'nkf'
require 'rexml/document'

@index = "/path/to/this/cgi"
@lwws_path = "/path/to/diary/cache/lwws"
@diary_index = "/path/to/diary/cgi"
@theme = "default"

def calendar2_make_cal(year, month)
	result = []
	t = Time.local(year, month, 1)
	r = Array.new(t.wday, nil)
	r << 1
	2.upto(31) do |i|
		break if Time.local(year, month, i).month != month
		r << i
	end
	r += Array.new((- r.size) % 7, nil)
	0.step(r.size - 1, 7) do |i|
		result << r[i, 7]
	end
	result
end

def calendar2_make_anchor(ym, str)
	if ym
		%Q|<a href="#{@index}?date=#{ym}">#{str}</a>|
	else
		str
	end
end

def calendar2_prev_current_next(date)
	yyyymm = date.strftime("%Y%m")
	if( date.month.to_i == 1 )
		yms = [(date.year.to_i - 1).to_s + "12", yyyymm, yyyymm.to_i + 1]
	elsif( date.month.to_i == 12 )
		yms = [yyyymm.to_i - 1, yyyymm, (date.year.to_i + 1).to_s + "01"]
	else
		yms = [yyyymm.to_i - 1, yyyymm, yyyymm.to_i + 1]
	end
	return yms
end

def lwws_to_html( date )
	file_name = "#{@lwws_path}/#{date}.xml"

	begin
		xml = File::read( file_name )

		doc = REXML::Document::new( xml ).root
		title = NKF::nkf('-We', doc.elements["image/title"].text)
		url = doc.elements["image/url"].text
		width = doc.elements["image/width"].text
		height = doc.elements["image/height"].text

		result = ""
		result << %Q|<div class="lwws">|
		result << %Q|<img src="#{url}" border="0" alt="#{title}" title="#{title}" width=#{width} height="#{height}" />|
		result << %Q|</div>|

		return result

	rescue Errno::ENOENT
		return ''
	end
end

def make_weather_cal( date )

	ymd = Time.parse(date + "01")

	year = ymd.year
	month = ymd.month
	p_c_n = calendar2_prev_current_next( ymd )
	days_format = ["日","月","火","水","木","金","土"]
	navi_format = ["前", "%d年<br>%d月", "次"]

	r = ""
	r << %Q[
		<html>
		<head>
		<title>livedoor Weather Calendar</title>
		<link rel="stylesheet" href="#{@diary_index}/theme/base.css" type="text/css" media="all">
		<link rel="stylesheet" href="#{@diary_index}/theme/#{@theme}/#{@theme}.css" title="pukiwiki" type="text/css" media="all">
		</head>
		<body>
		<h1>livedoor Weather Calendar</h1>
		<div class="day">
		<div class="body"><table><tr><td colspan="7"></td></tr>
		<tr>
	]

	r << %Q|<td align="center" colspan="2">#{calendar2_make_anchor(p_c_n[0], navi_format[0] % [year, month])}</td>|
	r << %Q|<td align="center" colspan="3">#{calendar2_make_anchor(p_c_n[1], navi_format[1] % [year, month])}</td>|
	r << %Q|<td align="center" colspan="2">#{calendar2_make_anchor(p_c_n[2], navi_format[2] % [year, month])}</td>|

	r << %Q[
		</tr>
		<tr>
	]

	0.upto(6) do |i|
		r <<%Q|<td align="center">#{days_format[i]}</td>|
	end

	r << %Q|</tr>|

	calendar2_make_cal(year, month).each do |week|
		r << %Q|<tr>|
		week.each do |day|
			if day == nil
				r <<  %Q| <td></td>\n|
			else
				date = "%04d%02d%02d" % [year, month, day]
				r << %Q| <td align="center">#{day.to_s}日<br />%s</td>\n| % lwws_to_html(date)
			end
		end
		r << %Q|</tr>|
	end

	r << %Q[
		</table>
		</div>
		</div>
		</body>
		</html>
	]
	return r
end

BEGIN { $defout.binmode }
$KCODE = 'n'

begin
	@cgi = CGI::new
	date = @cgi.params['date'][0]
	date = Time.now.strftime("%Y%m") if not date or not /^\d{6}$/ =~ date

	print @cgi.header('type' => 'text/html', 'charset' => 'euc-jp')
	print make_weather_cal( date )
rescue Exception
	if @cgi then
		print @cgi.header( 'status' => '500 Internal Server Error', 'type' => 'text/html' )
	else
		print "Status: 500 Internal Server Error\n"
		print "Content-Type: text/html\n\n"
	end
	puts "<h1>500 Internal Server Error</h1>"
	puts "<pre>"
	puts "#$! (#{$!.class})"
	puts ""
	puts $@.join( "\n" )
	puts "</pre>"
	puts "<div>#{' ' * 500}</div>"
end
