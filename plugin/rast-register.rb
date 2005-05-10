#!/usr/bin/env ruby
require 'rast'
require 'htree'

mode = ""
if $0 == __FILE__
	require 'cgi'
	ARGV << '' # dummy argument against cgi.rb offline mode.
	@cgi = CGI::new
	mode = @cgi.request_method ? "CGI" : "CMD"
else
	mode = "PLUGIN"
end

if mode == "CMD" || mode == "CGI"
	tdiary_path = "."
	tdiary_conf = "."
	$stdout.sync = true

	if mode == "CMD"
		def usage
			puts "rast-register.rb $Revision: 1.5 $"
			puts " register to rast index files from tDiary's database."
			puts " usage: ruby rast-regiser.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
			exit
		end

		require 'getoptlong'
		parser = GetoptLong::new
		parser.set_options(['--path', '-p', GetoptLong::REQUIRED_ARGUMENT], ['--conf', '-c', GetoptLong::REQUIRED_ARGUMENT])
		begin
			parser.each do |opt, arg|
				case opt
				when '--path'
					tdiary_path = arg
				when '--conf'
					tdiary_conf = arg
				end
			end
		rescue
			usage
			exit( 1 )
		end
	else
		@options = Hash.new
		File::readlines("tdiary.conf").each {|item| 
			if item =~ /@options/
				eval(item)
			end
		}
	end

	tdiary_conf = tdiary_path unless tdiary_conf
	Dir::chdir( tdiary_conf )

	begin
		$:.unshift tdiary_path
		require "#{tdiary_path}/tdiary"
	rescue LoadError
		$stderr.puts "rast-register.rb: cannot load tdiary.rb. <#{tdiary_path}/tdiary>\n"
		$stderr.puts " usage: ruby rast-regiser.rb [-p <tDiary directory>] [-c <tdiary.conf directory>]"
		exit( 1 )
	end
end

module TDiary
	#
	# Database
	#
	class RastDB
		DB_OPTIONS = {
			"preserve_text" => true,
			"properties" => [
				{
					"name" => "title",
					"type" => Rast::PROPERTY_TYPE_STRING,
					"search" => false,
					"text_search" => true,
					"full_text_search" => false,
					"unique" => false,
				},
				{
					"name" => "date",
					"type" => Rast::PROPERTY_TYPE_STRING,
					"search" => true,
					"text_search" => false,
					"full_text_search" => false,
					"unique" => false,
				},
				{
					"name" => "last_modified",
					"type" => Rast::PROPERTY_TYPE_DATE,
					"search" => true,
					"text_search" => false,
					"full_text_search" => false,
					"unique" => false,
				}
			]
		}

		attr_accessor :db
		attr_reader :conf, :encoding

		def initialize(conf, encoding)
			@conf = conf
			@encoding = encoding
			@db_options = {'encoding' => @encoding}.update(DB_OPTIONS)
		end

		def transaction
			if !File.exist?(db_path)
				Rast::DB.create(db_path, @db_options)
			end
			Rast::DB.open(db_path, Rast::DB::RDWR, "sync_threshold_chars" => 500000) { |@db|
				yield self
			}
		end

                def cache_path
                        @conf.cache_path || "#{@conf.data_path}cache"
                end

		def db_path
			"#{cache_path}/rast".untaint
		end
	end

	#
	# Register
	#
	class RastRegister < TDiaryBase
		def initialize(rast_db, diary)
			@db = rast_db.db
			super(CGI::new, 'day.rhtml', rast_db.conf)
			@diary = diary
			@encoding = rast_db.encoding
			@date = diary.date
			@diaries = {@date.strftime('%Y%m%d') => @diary} if @diaries.empty?
		end

		def execute(force = false)
			date = @date.strftime('%Y%m%d')
			last_modified = @diary.last_modified.strftime("%FT%T")
			options = {"properties" => ['last_modified']}
			result = @db.search("date = #{date}", options)
			item, = result.items
			if item
				if force || item.properties.first < last_modified
					@db.delete(item.doc_id)
				else
					return
				end
			end
			return unless @diary.visible?
			htree = HTree.parse(convert(eval_rhtml.untaint))
			title = @diary.title
			body = "#{title}\n"
			htree.traverse_element('{http://www.w3.org/1999/xhtml}div') {|i|
				case i.get_attribute('class').to_s
				when 'section', /commentbody/
					body << i.extract_text.to_s
				end
			}
			properties = {
				"title" => title,
				"date" => date,
				"last_modified" => last_modified,
			}
			@db.register(body, properties)
		end
		
		protected

		def mode; 'day'; end
		def cookie_name; ''; end
		def cookie_mail; ''; end

		def convert(str)
			case @encoding
			when 'utf8'
				NKF::nkf('-w -m0', str)
			else
				str
			end
		end
	end

	#
	# Main
	#
	class RastRegisterMain < TDiaryBase
		def initialize(conf, encoding)
			super(CGI::new, 'day.rhtml', conf)
			calendar
			RastDB.new(conf, encoding).transaction do |rast_db|
				@years.keys.sort.each do |year|
					print "(#{year.to_s}/) "
					@years[year.to_s].sort.each do |month|
						@io.transaction(Time::local(year.to_i, month.to_i)) do |diaries|
							diaries.sort.each do |day, diary|
								RastRegister.new(rast_db, diary).execute
								print diary.date.strftime('%m%d ')
							end
							false
						end
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
			<h1>Rast Register for tDiary</h1>
			<p>$Revision: 1.5 $</p>
			<p>Copyright (C) 2005 Kazuhiko &lt;kazuhiko@fdiary.net &gt;<br>Copyright (C) 2002 MUTOH Masao &lt;mutoh@highway.ne.jp&gt;</p>
			<p>Start!</p><hr>
		]
	end

	begin
		require 'cgi'
		if TDiary::Config.instance_method(:initialize).arity > 0
			# for tDiary 2.1 or later
			cgi = CGI.new
			conf = TDiary::Config::new(cgi)
		else
			# for tDiary 2.0 or earlier
			conf = TDiary::Config::new
		end
		conf.header = ''
		conf.footer = ''
		conf.show_comment = true
		conf.hide_comment_form = true
		def conf.bot?; true; end
		encoding = conf.options['rast.encoding'] || 'euc_jp'
		TDiary::RastRegisterMain.new(conf, encoding)
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
		encoding = @options['rast.encoding'] || 'euc_jp'
		TDiary::RastDB.new(conf, encoding).transaction do |rast_db|
			TDiary::RastRegister.new(rast_db, diary).execute(true)
		end
	end
end
