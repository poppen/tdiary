#!/usr/bin/env ruby
# tb.rb $Revision: 1.2 $
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
# derived from sheepman's tb.rb. Thanks to sheepman <sheepman@tcn.zaq.ne.jp>
# 

$KCODE= 'e'
BEGIN { $defout.binmode }

begin
	require 'tdiary'
  
	module TDiary
		class Comment
			def visible_true?
				@show
			end

			def visible?
				@show and /^(Track|Ping)Back$/ !~ name
			end
		end

		class TDiaryTrackBackError < StandardError
		end

		class TDiaryTrackBackBase < TDiaryBase
			public :mode
			def initialize( cgi, rhtml, conf )
				super
				date = ENV['REQUEST_URI'].scan(%r!/(\d{4})(\d\d)(\d\d)!)[0]
				@date = Time::local(*date)
			end

			def referer?
				nil
			end

			def trackback_url
				'http://' + ENV['SERVER_NAME'] +
					(ENV['SERVER_PORT'] == '80' ? '' : ENV['SERVER_PORT']) +
					ENV['REQUEST_URI']
			end

			def diary_url
				trackback_url.sub(/#{File::basename(ENV['SCRIPT_NAME'])}.*$/, '') +
					@conf.index.sub(%r|^\./|, '') +
					@plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
			end

			def self.success_response
				<<HERE
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>0</error>
</response>
HERE
			end

			def self.fail_response(reason)
				<<HERE
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>1</error>
<message>#{reason}</message>
</response>
HERE
			end
		end

		class TDiaryTrackBackList < TDiaryTrackBackBase
			def initialize( cgi, rhtml, conf )
				super
				@io.transaction( @date ) do |diaries|
					@diaries = diaries
					@diary = @diaries[@date.strftime('%Y%m%d')]
					DIRTY_NONE
				end
			end

			def eval_rhtml( prefix = '' )
				raise TDiaryTrackBackError.new("invalid date: #{@date.strftime('%Y%m%d')}") unless @diary
				@plugin = load_plugins
				r = <<RSSHEAD
<?xml version="1.0" encoding="EUC-JP"?>
<response>
<error>0</error>
<rss version="0.91">
<channel>
<title>#{@diary.title}</title>
<link>#{diary_url}</link>
<description></description>
<language>ja-jp</language>
RSSHEAD
				@diary.each_comment(100) do |com, idx|
					next unless com.visible_true?
					next unless /^(Track|Ping)Back$/ =~ com.name
					url, blog_name, title, excerpt = com.body.split(/\n/, 4)
					r << <<RSSITEM
<item>
<title>#{title}</title>
<link>#{url}</link>
<description>#{excerpt}</description>
</item>
RSSITEM
				end
				r << <<RSSFOOT
</channel>
</rss>
</response>
RSSFOOT
			end
		end

		class TDiaryTrackBackReceive < TDiaryTrackBackBase
			def initialize( cgi, rhtml, conf )
				super
				@error = nil

				url = @cgi.params['url'][0]
				blog_name = (@cgi.params['blog_name'][0] || '').to_euc
				title = (@cgi.params['title'][0] || '').to_euc
				excerpt = (@cgi.params['excerpt'][0] || '').to_euc

				body = [url, blog_name, title, excerpt].join("\n")
				@comment = Comment::new('TrackBack', '', body)
				begin
					@io.transaction( @date ) do |diaries|
						@diaries = diaries
						if @diaries[@date.strftime('%Y%m%d')].add_comment(@comment)
							DIRTY_COMMENT
						else
							@error = "repeated TrackBack Ping"
							DIRTY_NONE
						end
					end
				rescue
					@error = $!.message
				end
			end

			def eval_rhtml( prefix = '' )
				raise TDiaryTrackBackError.new(@error) if @error
				@plugin = load_plugins
				TDiaryTrackBackBase::success_response
			end
		end

		class TDiaryTrackBackShow < TDiaryTrackBackBase
			def eval_rhtml( prefix = '' )
				@plugin = load_plugins
				anchor = @plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
				raise ForceRedirect::new("../#{@conf.index}#{anchor}#t")
			end
		end
	end

	@cgi = CGI::new
	conf = TDiary::Config::new
	tdiary = nil

	begin
		if /POST/i === @cgi.request_method and @cgi.valid?( 'url' )
			tdiary = TDiary::TDiaryTrackBackReceive::new( @cgi, nil, conf )
		elsif @cgi.valid?( '__mode') and @cgi.params['__mode'][0] == 'rss'
			tdiary = TDiary::TDiaryTrackBackList::new( @cgi, nil, conf )
		end
	rescue TDiary::TDiaryError
	end
	tdiary = TDiary::TDiaryTrackBackShow::new( @cgi, nil, conf ) unless tdiary

	head = {
		#'type' => 'application/xml'
		'type' => 'text/xml',
		'Vary' => 'User-Agent'
	}
	body = ''
	begin
		body = tdiary.eval_rhtml
		head['charset'] = conf.charset
		head['Content-Length'] = body.size.to_s
		head['Pragma'] = 'no-cache'
		head['Cache-Control'] = 'no-cache'
		print @cgi.header( head )
		print body
	rescue TDiary::TDiaryTrackBackError
		head = {
			#'type' => 'application/xml'
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
