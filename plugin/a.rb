# a.rb $Revision: 1.7 $
#
# Create anchor easily.
#
# 1. Usage
# a(url, name)
#
#   a "http://www.hoge.com/diary/", "Hoge Diary"
#
# a(key, option_or_name = "", name = nil)
#   Use dictionary file. You need to create the dictionary 
#   file with a CGI.
#   a "home"
#   a "home", "20020329.html", "Here"
#
# a("name|key:option")
#   Use dictionary file. You need to create the dictionary 
#   file with a CGI.
#
#   a "key"
#   a "key:20020329.html"
#   a "key:20020329.html|Here"
#   a "Hoge Diary|http://www.hoge.com/diary/"
#   a "Hoge Diary|20020201.html#p01"  #=> Same as "my" plugin
#
# 4. Documents
# See URLs below for more details.
#   http://ponx.s5.xrea.com/hiki/a.rb.html (English) 
#   http://ponx.s5.xrea.com/hiki/ja/a.rb.html (Japanese) 
# 
# Copyright (c) 2002,2003 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
# 
require 'nkf'

A_REG_PIPE = /\|/
A_REG_COLON = /\:/
A_REG_URL = /:\/\//
A_REG_CHARSET = /euc|sjis|jis/
A_REG_CHARSET2 = /sjis|jis/
A_REG_CHARSET3 = /euc/
A_REG_MY = /^\d{8}/

if @options and @options["a.path"] 
	a_path = @options["a.path"]
else
	a_path = @cache_path + "/a.dat"
end

@a_anchors = Hash.new
if FileTest::exist?(a_path)
	open(a_path) do |file|
		file.each_line do |line|
			key, baseurl, *data = line.split(/\s+/)
			if data.last =~ A_REG_CHARSET
				charset = data.pop
			else
				charset = ""
			end
			@a_anchors[key] = [baseurl, data.join(" "), charset]
		end
	end
end

def a_separate(word)
	if A_REG_PIPE =~ word
		name, data = $`, $'
	else
		name, data = nil, word
	end

	option = nil
	if data =~ A_REG_URL
		key = data
	elsif data =~ A_REG_COLON
		key, option = $`, $'
	else
		key = data #Error pattern
	end
	[key, option, name]
end

def a_convert_charset(option, charset)
	return "" unless option
	return option unless charset
	if charset =~ A_REG_CHARSET2
		ret = CGI.escape(NKF::nkf("-#{charset[0].chr}", option))
	elsif charset =~ A_REG_CHARSET3
		ret = CGI.escape(option)
	else
		ret = option
	end
	ret
end

def a_anchor(key)
	data = @a_anchors[key]
	if data
		data.collect{|v| v ? v.dup : nil}
	else
		[nil, nil, nil]
	end
end

def a(key, option_or_name = nil, name = nil, charset = nil)
	url, value, cset = a_anchor(key)
	if url.nil?
		key, option, name = a_separate(key)
		url, value, cset = a_anchor(key)
		option_or_name = option unless option_or_name;
	end
	charset = cset unless charset
	
	value = key if value == ""

	if url.nil?
		url = key
		if name
			value = name
			url += a_convert_charset(option_or_name, charset)
		elsif option_or_name
			value = option_or_name 
		else
			value = key
		end
	else
		url += a_convert_charset(option_or_name, charset)
		value = name if name
	end

   if key =~ A_REG_MY
      option_or_name = key unless option_or_name
      return my(option_or_name, name)
   end

	if @options["a.tlink"] 
		if defined?(tlink)
			url.untaint
			result = tlink(url, value)
		else
			result = "tlink is not available."
		end
	else
		result = %Q[<a href="#{CGI.escapeHTML(url)}">#{value}</a>]
	end
	result
end

def navi_a(name = "a.rb conf")
	"<span class=\"adminmenu\"><a href=\"a_conf.rb\">#{name}</a></span>\n"
end

