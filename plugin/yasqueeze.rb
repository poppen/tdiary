#!/usr/bin/env ruby
# yasqueeze.rb $Revision: 1.4 $
#
# yasqueeze version 1.2.0
#
# Yet Another make HTML text files from tDiary's database.
#
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
# The original version of this file was distributed with squeeze 
# version 1.0.4 by TADA Tadashi <sho@spc.gr.jp> with GPL2.
$KCODE= 'e'

mode = ""
if $0 == __FILE__
  mode = ENV["REQUEST_METHOD"]? "CGI" : "CMD"
else
  mode = "PLUGIN"
end

if mode == "CMD" || mode == "CGI"
  output_path = "./html/"
  tdiary_path = "."
  tdiary_conf = "."
  all_data = false
  compat = false
  $stdout.sync = true

  if mode == "CMD"
	def usage
	  puts "yasqueeze $Revision: 1.4 $"
      puts " Yet Another making html files from tDiary's database."
	  puts " usage: ruby yasqueeze.rb [-p <tDiary path>] [-c <tdiary.conf path>] [-a] [-s] <dest path>"
	  exit
	end

	require 'getoptlong'
	parser = GetoptLong::new
	parser.set_options(['--path', '-p', GetoptLong::REQUIRED_ARGUMENT],
					   ['--conf', '-c', GetoptLong::REQUIRED_ARGUMENT],
					   ['--all', '-a', GetoptLong::NO_ARGUMENT],
					   ['--squeeze', '-s', GetoptLong::NO_ARGUMENT])
	begin
	  parser.each do |opt, arg|
		case opt
		when '--path'
		  tdiary_path = arg
		when '--conf'
		  tdiary_conf = arg
		when '--all'
		  all_data = true
		when '--squeeze'
		  compat = true
		end
	  end
	rescue
	  usage
	end
	output_path = ARGV.shift
	usage unless output_path
	output_path = File::expand_path(output_path)
	output_path += '/' if /\/$/ !~ output_path
  else
	@options = Hash.new
	File::readlines("tdiary.conf").each {|item| 
	  if item =~ /@options/
		eval(item)
	  end
	}
	output_path = @options['yasqueeze.output_path']
	all_data = @options['yasqueeze.all_data']
	compat = @options['yasqueeze.compat_path']
  end

  tdiary_conf = tdiary_path unless tdiary_conf
  Dir::chdir( tdiary_conf )

  begin
	ARGV << '' # dummy argument against cgi.rb offline mode.
	require "#{tdiary_path}/tdiary"
  rescue LoadError
	$stderr.print "yasqueeze.rb: cannot load tdiary.rb. <#{tdiary_path}/tdiary>\n"
	exit
  end
end

#
# Dairy Squeeze
#
class YATDiarySqueeze < TDiary
  def initialize(diary, dest, all_data, compat)
    super(nil, 'day.rhtml')
    @header = ''
    @footer = ''
	@show_comment = true
	@show_referer = false
	@diary = diary
	@dest = dest
	@all_data = all_data
	@compat = compat
  end

  def execute
	if @compat
	  dir = @dest
	  name = @diary.date.strftime('%Y%m%d')
	else
	  dir = @dest + "/" + @diary.date.strftime('%Y')
	  name = @diary.date.strftime('%m%d')
	  Dir.mkdir(dir, 0755) unless File.directory?(dir)
	end
	filename = dir + "/" + name
	if @diary.visible? or @all_data
	  if not FileTest::exist?(filename) or 
		  File::mtime(filename) < @diary.last_modified
		File::open(filename, 'w'){|f| f.write(eval_rhtml)}
	  end
	else
	  if FileTest.exist?(filename) and ! @all_data
		name = "remove #{name}"
		File::delete(filename)
	  else
		name = ""
	  end
	end
	name
  end
  
  protected
  def title
	t = @html_title
	t += "(#{@diary.date.strftime('%Y-%m-%d')})" if @diary
	t
  end

  def cookie_name; ''; end
  def cookie_mail; ''; end
end

#
# Main
#
class YATDiarySqueezeMain < TDiary
  def initialize(dest, all_data, compat)
	super(nil, 'day.rhtml')
	make_years
	@years.keys.sort.each do |year|
	  @years[year.to_s].sort.each do |month|
		transaction(Time::local(year.to_i, month.to_i)) do |diaries|
		  diaries.sort.each do |day, diary|
			print YATDiarySqueeze.new(diary, dest, all_data, compat).execute + " "
		  end
		  false
		end
	  end
	end
  end
end

if mode == "CGI" || mode == "CMD"
  if mode == "CGI"
	print %Q[Content-type:text/html\n\n
	  <html>
      <head>
        <title>Yet Another Squeeze for tDiary</title>
        <link href="./theme/default.css" type="text/css" rel="stylesheet"/>
      </head>
      <body><div style="text-align:center">
      <h1>Yet Another Squeeze for tDiary</h1>
      <p>$Revision: 1.4 $</p>
      <p>Copyright (C) 2002 MUTOH Masao&lt;mutoh@highway.ne.jp&gt;</p></div>
      <br><br>Start!</p><hr>
    ]
  end

  begin
	YATDiarySqueezeMain.new(output_path, all_data, compat)
  rescue
	print $!, "\n"
	$@.each do |v|
	  print v, "\n"
	end
  end

  if mode == "CGI"
	print "<hr><p>End!</p></body></html>\n"
  else
	print "\n\n"
  end
else
  add_update_proc do
	diary = @diaries[@date.strftime('%Y%m%d')]
	YATDiarySqueeze.new(diary, @options['yasqueeze.output_path'],
						@options['yasqueeze.all_data'],
						@options['yasqueeze.compat_path']).execute
  end
end
