# counter.rb $Revision: 1.2 $
#
# カウンタ表示プラグイン
#
# counter: 全ての訪問者数を表示する
#	パラメタ：
#	 figure: 表示桁数。未指定時は5桁。
#	 filetype: ファイル種別(拡張子)。jpg, gif, png等。
#						 未指定時は、""(画像は使わない、CSSで外見を変える)。
#	 init_num: 初期値。未指定時は0。
#
# counter_today: 本日の訪問者数を表示する
# counter_yesterday: 昨日の訪問者数を表示する
#	パラメタ：
#	 figure: 表示桁数。未指定時は5桁。
#	 filetype: ファイル種別(拡張子)。jpg, gif, png等。
#						 未指定時は、""(画像は使わない、CSSで外見を変える)。
#
# 例：
# counter
# counter 3
# coutner 3, "jpg"
# counter 5, "", 100
# counter_today 4, "jpg"
# counter_yesterday
#
# CSSクラス:（各テーマのCSSファイルに入れてください。省略可）
#	 counter: 対象文字列全体(全て)
#	 counter-today: 対象文字列全体(今日)
#	 counter-yesterday: 対象文字列全体(昨日)
#	 counter-0, ... : 1桁分(左から)
#	 counter-num-0, ... 9: 数字
#
# その他の情報は 
#   http://home2.highway.ne.jp/mutoh/tools/ruby/ja/counter.html
# を参照してください。
#
# Copyright (c) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
# 
=begin ChangeLog
2002-04-27 MUTOH Masao  <mutoh@highway.ne.jp>
	* add_header_procを使わないようにした
	* @options["counter.timer"]が有効にならない不具合の修正
	* @options["counter.log"]追加。trueを指定するとcounter.dat
	   と同じディレクトリにcounter.logというファイルを作成し
	   1日前のアクセス数を記録するようにした
	* cookieの値としてバージョン番号を入れるようにした
	* version 1.1.0

2002-04-25 MUTOH Masao  <mutoh@highway.ne.jp>
	* HEADでアクセスがあった場合に再びカウントされるように
		なってしまっていた不具合の修正(by NT<nt@24i.net>)
	* version 1.0.4

2002-04-24 MUTOH Masao  <mutoh@highway.ne.jp>
	* ツッコミを入れたときにエラーが発生する不具合の修正
	* version 1.0.3

2002-04-23 MUTOH Masao	<mutoh@highway.ne.jp>
	* データファイルを削除後、クッキーが有効期間中の端末から
		アクセスした場合に@todayが0になる不具合の修正
	* コメント入れたときに数字が表示されない不具合の修正
	* HEADでアクセスがあった場合はカウントしないようにした
		(reported by NT<nt@24i.net>, suggested a solution 
			by TADA Tadashi <sho@spc.gr.jp>)
	* version 1.0.2

2002-04-21 MUTOH Masao	<mutoh@highway.ne.jp>
	* CSSで_を使っているところを-に直した(reported by NT<nt@24i.net>)
	* TDiaryCountData#upで@allが+1されない不具合の修正
	* version 1.0.1

2002-04-14 MUTOH Masao	<mutoh@highway.ne.jp>
	* version 1.0.0
=end

if ["latest", "month", "day", "comment"].include?(@mode) and
		@cgi.request_method =~ /POST|GET/

require 'date'

eval(<<TOPLEVEL_CLASS, TOPLEVEL_BINDING)
class TDiaryCountData
	attr_reader :today, :yesterday, :all, :newestday, :timer

	def initialize
		@today, @yesterday, @all = 0, 0, 0
		@newestday = nil
	end

	def up(now, cache_path, log)
		if now == @newestday
			@today += 1
		else
			log(@newestday, @today, cache_path) if log
			@yesterday = ((now - 1) == @newestday) ? @today : 0
			@today = 1
			@newestday = now
		end
		@all += 1
	end

	def log(day, value, path)
		return unless day
		open(path + "/counter.log", "a") do |io|
			io.print day, " : ", value, "\n"
		end
	end
end
TOPLEVEL_CLASS

module TDiaryCounter
	@version = "1.1.0"

	def run(cache_path, cgi, options)
		timer = options["counter.timer"] if options
		timer = 12 unless timer	# 12 hour
		dir = cache_path + "/counter"
		path = dir + "/counter.dat"
		cookie = nil
	
		Dir.mkdir(dir, 0700) unless FileTest.exist?(dir)
	
		db = PStore.new(path)
		db.transaction do
			begin
				@cnt = db["countdata"]
			rescue PStore::Error
				@cnt = TDiaryCountData.new
				cgi.cookies = nil
			end
			if ! cgi.cookies or ! cgi.cookies.keys.include?("tdiary_counter")
				@cnt.up(Date.today, dir, (options and options["counter.log"]))
				cookie = CGI::Cookie.new({"name" => "tdiary_counter", 
													"value" => @version, 
													 "expires" => Time.now + timer * 3600})
				db["countdata"] = @cnt
			end
		end
		cookie
	end

	def format(classtype, theme_url, cnt, figure = 5, filetype = "", init_num = 0, &proc)
		str = "%0#{figure}d" % (cnt + init_num)
		result = %Q[<span class="counter#{classtype}">]
		depth = 0
		str.scan(/./).each do |num|
			if block_given?
				result << %Q[<img src="#{theme_url}/#{yield(num)}" alt="#{num}" />]
			elsif filetype == ""
				result << %Q[<span class="counter-#{depth}"><span class="counter-num-#{num}">#{num}</span></span>]
			else 
				result << %Q[<img src="#{theme_url}/#{num}.#{filetype}" alt="#{num}" />]
			end
			depth += 1
		end
		result << "</span>"
	end

	def called?; @called; end
	def called; @called = true; end
	def all; @cnt.all; end
	def today; @cnt.today; end
	def yesterday; @cnt.yesterday; end

	module_function :all, :today, :yesterday, :format, :run
end

def counter(figure = 5, filetype = "", init_num = 0, &proc)
	TDiaryCounter.format("", theme_url, TDiaryCounter.all, figure, filetype, init_num, &proc)
end

def counter_today(figure = 5, filetype = "", &proc)
	TDiaryCounter.format("-today", theme_url, TDiaryCounter.today, figure, filetype, 0, &proc)
end

def counter_yesterday(figure = 5, filetype = "", &proc)
	TDiaryCounter.format("-yesterday", theme_url, TDiaryCounter.yesterday, figure, filetype, 0, &proc)
end

tdiary_counter_cookie = TDiaryCounter.run(@cache_path, @cgi, @options)
if tdiary_counter_cookie
	if defined?(add_cookie)
		add_cookie(tdiary_counter_cookie)
	else
		@cookie = tdiary_counter_cookie if tdiary_counter_cookie
	end
end

end
