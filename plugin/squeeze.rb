#!/usr/bin/env ruby

# squeeze.rb $Revision: 1.21 $
#
# Create daily HTML file from tDiary database.
#
# See URLs below for more details.
#   http://ponx.s5.xrea.com/hiki/squeeze.rb.html (English) 
#   http://ponx.s5.xrea.com/hiki/ja/squeeze.rb.html (Japanese) 
#
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
# The original version of this file was distributed with squeeze 
# version 1.0.4 by TADA Tadashi <sho@spc.gr.jp> with GPL2.
#

mode = ""
if $0 == __FILE__
	require 'cgi'
	@cgi = CGI::new
	mode = @cgi.request_method ? "CGI" : "CMD"
else
	mode = "PLUGIN"
end

if mode == "CMD" || mode == "CGI"
	output_path = "./html/"
	tdiary_path = "."
	tdiary_conf = "."
	suffix = ''
	all_data = false
	compat = false
	$stdout.sync = true

	if mode == "CMD"
		def usage
			puts "squeeze $Revision: 1.21 $"
			puts " making html files from tDiary's database."
			puts " usage: ruby squeeze.rb [-p <tDiary path>] [-c <tdiary.conf path>] [-a] [-s] [-x suffix] <dest path>"
			exit
		end

		require 'getoptlong'
		parser = GetoptLong::new
		parser.set_options(['--path', '-p', GetoptLong::REQUIRED_ARGUMENT],
											 ['--conf', '-c', GetoptLong::REQUIRED_ARGUMENT],
											 ['--suffix', '-x', GetoptLong::REQUIRED_ARGUMENT],
											 ['--all', '-a', GetoptLong::NO_ARGUMENT],
											 ['--squeeze', '-s', GetoptLong::NO_ARGUMENT])
		begin
			parser.each do |opt, arg|
				case opt
				when '--path'
					tdiary_path = arg
				when '--conf'
					tdiary_conf = arg
				when '--suffix'
					suffix = arg
				when '--all'
					all_data = true
				when '--squeeze'
					compat = true
				end
			end
		rescue
			usage
			exit( 1 )
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
		output_path = @options['squeeze.output_path'] || @options['yasqueeze.output_path']
		suffix = @options['squeeze.suffix'] || ''
		all_data = @options['squeeze.all_data'] || @options['yasqueeze.all_data']
		compat = @options['squeeze.compat_path'] || @options['yasqueeze.compat_path']
	end

	tdiary_conf = tdiary_path unless tdiary_conf
	Dir::chdir( tdiary_conf )

	begin
		ARGV << '' # dummy argument against cgi.rb offline mode.
		$:.unshift tdiary_path
		require "#{tdiary_path}/tdiary"
	rescue LoadError
		$stderr.print "squeeze.rb: cannot load tdiary.rb. <#{tdiary_path}/tdiary>\n"
		exit( 1 )
	end
end

#
# Dairy Squeeze
#
module TDiary
	class YATDiarySqueeze < TDiaryBase
		def initialize(diary, dest, all_data, compat, conf, suffix)
			@ignore_parser_cache = true
	
			super(CGI::new, 'day.rhtml', conf)
			@diary = diary
			@date = diary.date
			@diaries = {@date.strftime('%Y%m%d') => @diary} if @diaries.size == 0
			@dest = dest
			@all_data = all_data
			@compat = compat
			@suffix = suffix
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
			filename = dir + "/" + name + @suffix
			if @diary.visible? or @all_data
				if not FileTest::exist?(filename) or 
						File::mtime(filename) != @diary.last_modified
					File::open(filename, 'w'){|f| f.write(eval_rhtml)}
					File::utime(@diary.last_modified, @diary.last_modified, filename)
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
		def mode
			'day'
		end

		def cookie_name; ''; end
		def cookie_mail; ''; end
	end
end

#
# Main
#
module TDiary
	class YATDiarySqueezeMain < TDiaryBase
		def initialize(dest, all_data, compat, conf, suffix)
			@ignore_parser_cache = true
	
			super(CGI::new, 'day.rhtml', conf)
			calendar
			@years.keys.sort.each do |year|
				print "(#{year.to_s}/) "
				@years[year.to_s].sort.each do |month|
					@io.transaction(Time::local(year.to_i, month.to_i)) do |diaries|
						diaries.sort.each do |day, diary|
							print YATDiarySqueeze.new(diary, dest, all_data, compat, conf, suffix).execute + " "
						end
						DIRTY_NONE
					end
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
				<title>Squeeze for tDiary</title>
				<link href="./theme/default/default.css" type="text/css" rel="stylesheet"/>
			</head>
			<body><div style="text-align:center">
			<h1>Squeeze for tDiary</h1>
			<p>$Revision: 1.21 $</p>
			<p>Copyright (C) 2002 MUTOH Masao&lt;mutoh@highway.ne.jp&gt;</p></div>
			<br><br>Start!</p><hr>
		]
	end

	begin
		require 'cgi'
		cgi = CGI.new
		conf = TDiary::Config::new(cgi)
		conf.header = ''
		conf.footer = ''
		conf.show_comment = true
		conf.hide_comment_form = true
		def conf.bot?; true; end
		output_path = "#{conf.data_path}/cache/html" unless output_path
		Dir.mkdir(output_path, 0755) unless File.directory?(output_path)
		TDiary::YATDiarySqueezeMain.new(output_path, all_data, compat, conf, suffix)
	rescue
		print $!, "\n"
		$@.each do |v|
			print v, "\n"
		end
		exit( 1 )
	end

	if mode == "CGI"
		print "<hr><p>End!</p></body></html>\n"
	else
		print "\n\n"
	end
else
	add_update_proc do
		conf = @conf.clone
		conf.header = ''
		conf.footer = ''
		conf.show_comment = true
		conf.hide_comment_form = true
		def conf.bot?; true; end

		diary = @diaries[@date.strftime('%Y%m%d')]
		dir = @options['squeeze.output_path'] || @options['yasqueeze.output_path']
		dir = @cache_path + "/html" unless dir
		Dir.mkdir(dir, 0755) unless File.directory?(dir)
		TDiary::YATDiarySqueeze.new(diary, dir,
					    @options['squeeze.all_data'] || @options['yasqueeze.all_data'],
					    @options['squeeze.compat_path'] || @options['yasqueeze.compat_path'],
					    conf,
					    @options['squeeze.suffix'] || ''
					    ).execute
	end
end
