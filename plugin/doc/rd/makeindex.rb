#!/usr/bin/ruby
#  makeindex.rb -- make index.html from rd
#
#  Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
#  You may redistribute it and/or modify it under the same
#  license terms as Ruby.

class MakeIndex
  def header
	%Q[
<?xml version="1.0" encoding="euc-jp" ?>
<!DOCTYPE html 
  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>プラグインについて</title>
<meta http-equiv="Content-type" content="text/html; charset=euc-jp" />
<link href="./doc.css" type="text/css" rel="stylesheet"/>
</head>

<body>
<h1>プラグインについて</h1>
<p>tdiary-plugin添付のプラグインについて説明します。</p>
]
  end

  def footer
	%Q[
</body>
</html>
]
  end

  def execute
	open("../index.html", "w"){ |out|
	  out.print header
	  Dir.glob("*.rd").sort.each { |file|
		name = File.basename(file, ".rd")
		summary = false
		IO.readlines(file).each do |line|
		  if line =~ /^\= (.*)$/
			out.print %Q[<h2><a href="#{name}.html">#{$1}</a></h2>\n]
		  elsif line =~ /^== 機能/
			summary = true
			out.print "<p>\n"
		  elsif summary
			if line =~ /^\s*$/
			  out.print "</p>\n"
			  break
			else
			  out.print "  #{line.chop}<br>\n"
			end
		  end
		end
  	    $stdout.print("#{name}.rd >> ../index.html\n")
		out.print footer
	  }
	}
  end
end

if __FILE__ == $0
  MakeIndex.new.execute
end
