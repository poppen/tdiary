# counter.rb $Revision: 1.12 $
# -pv-
#
# 名称：
# カウンタ表示プラグイン
#
# 概要：
# 訪問者数を「全て」「今日」「昨日」に分けて表示します。
#
# 使う場所：
# ヘッダ、もしくはフッタ
# 
# 使い方：
# counter(figure, filetype): 全ての訪問者数を表示する
# counter_today(figure, filetype): 今日の訪問者数を表示する
# counter_yesterday(figure, filetype): 昨日の訪問者数を表示する
#	 figure: 表示桁数(実際の数が表示桁数に満たない場合は前0)。未指定時は前0無し。
#	 filetype: ファイル種別(拡張子)。jpg, gif, png等。
#						 未指定時は、""(画像は使わない、CSSで外見を変える)。
#
# kiriban?: キリ番の時にtrueを返す(全て)。
# kiriban_today?: キリ番の時にtrueを返す(今日)。
#
# 使用例：
# counter
# counter 3
# coutner 3, "jpg"
# counter_today 4, "jpg"
# counter_yesterday
#
# オプションについて：
# 初期値の指定　未指定時：0
#   @options["counter.init_num"] = 5
#
# ログの取得　未指定時：false
#   @options["counter.log"] = true
#
# 訪問間隔の指定(単位：時間)　未指定時：12
#   @options["counter.timer"] = 6
#
# 同一クライアントからの連続アクセスの非カウントアップ間隔の指定(単位：時間) 
# 未指定時：0.1(6分)
#   @options["counter.deny_same_src_interval"] = 0.1
#
# カウントアップ制限　未指定時：なし
#   @options['counter.deny_user_agents'] = ["w3m", "Mozilla/4"]
#   @options['counter.deny_remote_addrs'] = ["127.0", "10.0.?.1", "192.168.1.2"]
#
# キリ番　未指定時：なし
#   @options["counter.kiriban"] = [1000, 3000, 5000, 10000, 15000, 20000]
#   @options["counter.kiriban_today"] = [100, 200, 300, 400, 500, 600]
#
# 日々バックアップ　未指定時：有効
#   @options['counter.daily_backup'] = true
# 
# CSSについて:
#	 counter: 対象文字列全体(全て)
#	 counter-today: 対象文字列全体(今日)
#	 counter-yesterday: 対象文字列全体(昨日)
#	 counter-0, ... : 1桁分(左から)
#	 counter-num-0, ... 9: 数字
#	 counter-kiriban: キリ番の数字の部分(全て)
#	 counter-kiriban-today: キリ番の数字の部分(今日)
#
# その他：
#   http://home2.highway.ne.jp/mutoh/tools/ruby/ja/counter.html
# を参照してください。
#
# 著作権について：
# Copyright (c) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
# 
=begin ChangeLog
2002-08-30 MUTOH Masao  <mutoh@highway.ne.jp>
	* データファイルが読み込めなくなったとき、1つ前のバックアップデータ
	  を用いて復旧するようにした(その際に、1つ前のバックアップデータは
	  counter.dat.?.bakという名前でバックアップされる)。さらに1つ前の
	  バックアップデータからも復旧できなかった場合は全てのカウンタ値を
	  0にしてエラー画面が表示されないようにした。
   * version 1.6.0

2002-07-23 MUTOH Masao  <mutoh@highway.ne.jp>
   * バックアップファイルのファイル名のsuffixを曜日(0-6の数値)にした。
      従って、1週間毎に古いファイルは上書きされるのでファイルの数は
      最大7つとなる。数字が新しいものが最新というわけではないので注意。
      (proposed by Junichiro KITA <kita@kitaj.no-ip.com>)
   * version 1.5.1

2002-07-19 MUTOH Masao  <mutoh@highway.ne.jp>
   * 日々単位でデータをバックアップするようにした。
     @options["counter.dairy_backup"]で指定。falseを指定しない限り
     バックアップする。
   * Date#==メソッドでnilを渡さないように修正
   * require 'pstore'追加(tDiary version 1.5.x系対応)
   * logのフォーマット変更(全て・今日・昨日のデータを出力)
   * @options["counter.deny_same_src_interval"]のデフォルト値を2時間
     に変更した。
   * version 1.5.0

2002-05-19 MUTOH Masao  <mutoh@highway.ne.jp>
   * Cookieを使うことのできない同一クライアントからの連続アクセスを、
     カウントアップしないようにした。
   * @options["counter.deny_same_src_interval"]追加。連続GETの間隔を指定。
     デフォルトで0.1時間(6分)。
   * version 1.4.0

2002-05-11 MUTOH Masao  <mutoh@highway.ne.jp>
   * 初期値を与えない場合は5桁としていたが、「前0をなくす」に変更した。
     また、前0を無くす場合は0を指定しても良い。
   * version 1.3.0

2002-05-05 MUTOH Masao  <mutoh@highway.ne.jp>
   * @debug = true 削除 :->
   * コメント変更
   * version 1.2.1

2002-05-04 MUTOH Masao  <mutoh@highway.ne.jp>
   * tlinkプラグインからのアクセスをカウントしてしまう不具合の修正
   * @options["counter.deny_user_agents"]追加
   * @options["counter.deny_remote_addrs"]追加
   * @options["counter.init_num"]追加。キリ番機能との関係で、counter
   * メソッドの引数のinit_numはobsoleteとします。
   * @options["counter.kiriban"], @options["counter.kiriban_today"]追加
   * キリ番機能追加(kiriban?,kiriban_today?メソッド追加)
   * version 1.2.0

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

2002-04-23 MUTOH Masao  <mutoh@highway.ne.jp>
   * データファイルを削除後、クッキーが有効期間中の端末から
      アクセスした場合に@todayが0になる不具合の修正
   * コメント入れたときに数字が表示されない不具合の修正
   * HEADでアクセスがあった場合はカウントしないようにした
      (reported by NT<nt@24i.net>, suggested a solution 
         by TADA Tadashi <sho@spc.gr.jp>)
   * version 1.0.2

2002-04-21 MUTOH Masao  <mutoh@highway.ne.jp>
   * CSSで_を使っているところを-に直した(reported by NT<nt@24i.net>)
   * TDiaryCountData#upで@allが+1されない不具合の修正
   * version 1.0.1

2002-04-14 MUTOH Masao  <mutoh@highway.ne.jp>
   * version 1.0.0
=end

if ["latest", "month", "day", "comment"].include?(@mode) and 
	@cgi.request_method =~ /POST|GET/ 

require 'date'
require 'pstore'

eval(<<TOPLEVEL_CLASS, TOPLEVEL_BINDING)
class TDiaryCountData
	attr_reader :today, :yesterday, :all, :newestday, :ignore_cookie
	attr_writer :ignore_cookie #means ALWAYS ignore a cookie.

	def initialize
		@today, @yesterday, @all = 0, 0, 0
		@newestday = nil
		@ignore_cookie = false
	end

	def up(now, cache_path, cgi, log)
		if @newestday
			if now == @newestday
				@today += 1
			else
				log(@newestday, cache_path) if log
				@yesterday = ((now - 1) == @newestday) ? @today : 0
				@today = 1
				@newestday = now
			end
		else
			@yesterday = 0
			@today = 1
			@newestday = now
		end
		@all += 1
	end

	def previous_access_time(remote_addr, user_agent)
		@users = Hash.new unless @users
		ret = @users[[remote_addr, user_agent]]
		@users[[remote_addr, user_agent]] = Time.now
		ret
	end

	def log(day, path)
		return unless day
		open(path + "/counter.log", "a") do |io|
			io.print day, " : ", @all, ",", @today, ",", @yesterday, "\n"
		end
	end
end
TOPLEVEL_CLASS

module TDiaryCounter
	@version = "1.6.0"

	def run(cache_path, cgi, options)
		timer = options["counter.timer"] if options
		timer = 12 unless timer	# 12 hour
		@init_num = options["counter.init_num"] if options
		@init_num = 0 unless @init_num
		dir = cache_path + "/counter"
		path = dir + "/counter.dat"
		today = Date.today
		Dir.mkdir(dir, 0700) unless FileTest.exist?(dir)
	
		cookie = nil
		begin
			cookie = main(cache_path, cgi, options, timer, dir, path, today)
		rescue 
			back = (Dir.glob(path + ".?").sort{|a,b| File.mtime(a) <=> File.mtime(b)}.reverse)[0]
			copy(back, back + ".bak")
			copy(back, path)
			begin
				main(cache_path, cgi, options, timer, dir, path, today)
			rescue 
				@cnt = TDiaryCountData.new
			end
		end
		cookie
	end

	def main(cache_path, cgi, options, timer, dir, path, today)
		cookie = nil
		db = PStore.new(path)
		db.transaction do
			begin
				@cnt = db["countdata"]
			rescue PStore::Error
				@cnt = TDiaryCountData.new
				cgi.cookies = nil
			end

			allow = (cgi.user_agent !~ /tlink/ and
						allow?(cgi.user_agent, options, "user_agents") and
						allow?(cgi.remote_addr, options, "remote_addrs"))

			if allow 
				changed = false
				if new_user?(cgi, options)
					@cnt.up(today, dir, cgi, (options and options["counter.log"]))
					cookie = CGI::Cookie.new({"name" => "tdiary_counter", 
														"value" => @version, 
														 "expires" => Time.now + timer * 3600})
					changed = true
				end
				if options["counter.kiriban"]
					@kiriban = options["counter.kiriban"].include?(@cnt.all + @init_num) 
				end
 				if ! @kiriban and options["counter.kiriban_today"]
					@kiriban_today = options["counter.kiriban_today"].include?(@cnt.today)
				end

				if @cnt.ignore_cookie
					@cnt.ignore_cookie = false
					changed = true
				end

				#when it is kiriban time, ignore the cookie next access time. 
				if @kiriban or @kiriban_today
					@cnt.ignore_cookie = true
					changed = true
				end

				if changed
					if options["counter.daily_backup"] == nil || options["counter.daily_backup"] 
						copy(path, path + "." + today.wday.to_s)
					end
					db["countdata"] = @cnt
				end
			end
		end
		cookie
	end

	def copy(old, new)
		if FileTest.exist?(old)
			File.open(old,  'rb') {|r|
				File.open(new, 'wb') {|w|
					st = r.stat
					begin
						while true do
							w.write r.sysread(st.blksize)
						end
					rescue EOFError
					end
				} 
			}
		end
	end
		
	def allow?(cgi_value, options, option_name)
		allow = true
		if options and options["counter.deny_" + option_name] 
			options["counter.deny_" + option_name].each do |deny|
				if cgi_value =~ /#{deny}/
					allow = false
					break
				end
			end
		end
		allow 
	end

	def new_user?(cgi, options)
		if ! cgi.cookies or ! cgi.cookies.keys.include?("tdiary_counter")
			interval = options["counter.deny_same_src_interval"] if options
			interval = 2 unless interval	# 2 hour.
			previous_access_time = @cnt.previous_access_time(cgi.remote_addr, cgi.user_agent)
			if previous_access_time
				ret = Time.now - previous_access_time > interval * 3600
			else
				ret = true
			end
		else
			ret = @cnt.ignore_cookie
		end
		ret
	end

	def format(classtype, theme_url, cnt, figure = 0, filetype = "", init_num = 0, &proc)
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
	def all; @cnt.all + @init_num; end
	def today; @cnt.today; end
	def yesterday; @cnt.yesterday; end
	def kiriban?; @kiriban; end
	def kiriban_today?; @kiriban_today; end

	module_function :allow?, :new_user?, :all, :today, :yesterday, :format, 
							:main, :run, :copy, :kiriban?, :kiriban_today?
end

#init_num is deprecated.
#please replace it to @options["counter.init_num"]
def counter(figure = 0, filetype = "", init_num = 0, &proc) 
	TDiaryCounter.format("", theme_url, TDiaryCounter.all, figure, filetype, init_num, &proc)
end

def counter_today(figure = 0, filetype = "", &proc)
	TDiaryCounter.format("-today", theme_url, TDiaryCounter.today, figure, filetype, 0, &proc)
end

def counter_yesterday(figure = 0, filetype = "", &proc)
	TDiaryCounter.format("-yesterday", theme_url, TDiaryCounter.yesterday, figure, filetype, 0, &proc)
end

def kiriban?
	TDiaryCounter.kiriban?
end

def kiriban_today?
	TDiaryCounter.kiriban_today?
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
