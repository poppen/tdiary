#!/usr/bin/env ruby
=begin
= その日の天気プラグイン((-$Id: weather.rb,v 1.1 2003-05-09 11:21:13 zunda Exp $-))
その日の天気を、その日の日記を最初に更新する時に取得して保存し、それぞれ
の日の日記の上部に表示します。

== 入手方法
このファイルの最新版は、
((<URL:http://zunda.freeshell.org/d/plugin/weather.rb>))
にあります。

== 使い方
=== インストール方法
このファイルをpluginディレクトリにコピーしてください。漢字コードは
EUC-JPです。

次に、tdiary.confを編集して、天気データをいただいてくるURLを
@options['weather.url']に設定してください。

例えば、 NOAA National Weather Serviceを利用する場合には、
((<URL:http://weather.noaa.gov/>))から、Select a country...で国名を選ん
でGo!ボタンを押し、次に観測地点を選んでください。その時表示されたページ
のURLを、例えば、
  @options['weather.url'] = 'http://weather.noaa.gov/weather/current/RJTI.html'
と書いてください。この例では東京ヘリポート((-どこにあるんだろ？-))の天気
が記録されます。情報の二次利用が制限されている場合がありますので、そのよ
うなWWWページから情報を取得しないように注意してください。

さらに、将来日記のタイムゾーンが変化する可能性がある方は、今のタイムゾー
ンを、@options['weather.tz']に設定しておくことをお勧めします。これによっ
て、日記が引越した後も、天気データ取得時のタイムゾーンで天気を表示し続け
ることができます。例えば日本標準時の場合は、
  @options['weather.tz'] = 'Japan'
と設定してください。

これで、新しい日の日記を書く度に、設定したURLから天候データを取得して、
表示するようになるはずです。天気は、
  <div class="weather"><span class="weather">hh:mm現在<a href="取得元URL">天気(温度)</a></span></div>
という形式でそれぞれの日の日記の上に表示されます。必要ならば、CSSを編集
してください。
  div.weather {
    text-align: right;
    font-size: 75%;
  }
などとしておけばいいでしょう。

日記に使用しているWWWサーバーからサーバーの権限でWWWページの閲覧ができる
必要があります。環境変数TZを変更する場合がありますので、secureモードでは
使えません。mod_rubyでの動作は今のところ確認していません。

デフォルトでは、携帯端末から閲覧された場合には天気を表示しないようになっ
ています。携帯からでも天気を表示したい場合には、
  @options['weahter.show_mobile'] = true
を指定してください。

=== 保存される天気データについて
天気データは、
* 書いてる日記の日付と現在の日付が一致し、
* その日の天気データがまだ取得されていないか、前回の取得時にエラーがあった
場合に、取得されます。

天気データは、@options['weather.dir']に設定したディレクトリか、
@cache_path/weather/ ディレクトリ以下に、年/年月.weather というファイ ル
名で保存されます。タブ区切りのテキストファイルですので必要に応じて編集 
することができます。タブの数を変えてしまわないように気をつけて編集してく
ださい。フォーマットの詳細は、Weather.to_sメソッドを参照してください。

天気データには、データの取得時刻が記録されています。また、データの取得元
から得られた、天気の更新時刻が記録されていることもあります。これらの時刻
は、世界標準時(UNIX時刻)に直されて記録されていて、日記に表示する時に現地
時刻に直しています。このため、天気を記録した時のタイムゾーンと、天気を表
示する時のタイムゾーンが異なってしまうと、例えば朝の天気だったものが夕方
の天気として表示されてしまうことになります。これを防ぐには、例えば、
  @options['weather.tz'] = 'Japan'
というオプションを設定して、データにタイムゾーンを記録するようにしてくだ
さい。tdiary.confなどで、
  ENV['TZ'] = 'Japan'
などとして環境変数TZを設定することでも同様の効果が得られます。環境変数を
設定した場合は、tDiary全体の動作に影響がありますので留意してください。

なお、1.1.2.19かそれ以前のバージョンのweather.rbではタイムゾーンの情報が
天気データに記録されていません。お手数ですが、必要ならば、ファイルを編集
して、タイムゾーン情報を追加してください。記録ファイルは、デフォルトでは、
  .../cache/weather/2003/200301.weather
などにあります。取得元URLの次の数字がUNIX時刻ですので、それに続けて、空
白を一つと、Japanなどタイムゾーンを示す文字列を入力してください。データ
取得時にエラーがなければ、その後２つのタブに続いて、天気のデータが記録さ
れているはずです。

=== オプション
==== 必ず指定が必要な項目
: @options['weather.url']
  天気データを得られるWWWページのURL。
    @options['weather.url'] = 'http://weather.noaa.gov/weather/current/RJTI.html'
  など。情報の二次利用が制限されている場合がありますので、そのようなWWW
  ページから情報を取得しないように注意してください。

==== 指定しなくてもいい項目
: @options['weahter.show_mobile'] = false
  trueの場合は、携帯端末からのアクセスの場合に、i_html_stringで生成され
  たCHTMLを表示します。falseの場合は、携帯端末からのアクセスの場合には天
  気を表示しません。
  
: @options['weather.tz']
  データを取得した場所のタイムゾーン。コマンドライン上で例えば、
    TZ=Japan date
  を実行して正しい時刻が表示される文字列を設定してください。Linuxでは、
  /usr/share/zoneinfo以下のファイルネームを指定すればいいはずです。この
  オプションが指定されていない場合、環境変数TZが設定されていればその値を
  使用します。そうでなければタイムゾーンは記録しません。
    
  天気データにタイムゾーンが記録されていない場合は、もし将来日記のタイム
  ゾーンが変更された場合に違う時刻を表示することになります。
  
  日付の判定など、天気データの記録以外の時刻の管理には、日記全体のタイム
  ゾーンが用いられます。

: @options['weahter.show_error']
  データ取得時にエラーがあった場合にそれを日記に表示したい場合にはtrueに
  します。デフォルトでは表示しません。

: @options['weather.dir']
  データの保存場所。デフォルトは以下の通り。
    "#{@cache_path}/weather/"
  この下に、年/年月.weather というファイルが作られます。これを、
  @data_pathと同じにすると、日記のデータと同じディレクトリに天気のデータ
  を保存できるかもしれません。

: @options['weather.items']
  WWWページから取得する項目。デフォルトは、ソースをご覧ください。
  parse_htmlで得られる項目名をキー、記録する項目名を値としたハッシュです。
  www.nws.noaa.govのフォーマットに合わせて、多少の単位の変動には耐えられ
  るようにしてあります。これを変更する場合には、parse_htmlメソッドも編
  集する必要があるかもしれません。

: @options['weather.header']
  HTTPリクエストヘッダに追加する項目のハッシュ
    @options['weather.header'] = {'Accept-language' => 'ja'}
  など。((-Accept-languageによって取得する言語を選べるサイトもあります。-))
  デフォルトでは追加のヘッダは送信しません。

=== 天候の翻訳について
NWSからのデータは英語ですので、適当に日本語に直してから出力するようにし
てあります。翻訳は、WeatherTranslatorモジュールによっていて、変換表は、
Weatherクラスに、Words_jaという配列定数として与えてあります。

語彙はまだまだ充分ではないと思います。知らない単語は英語のまま表示されま
すので、Words_jaに適宜追加してください。
((<URL:http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?weather%2Erb>))
に書いておくと、そのうち配布元で追加されるかもしれません。

=== 細かい設定
天気データ取得元や好みに合わて、以下のメソッドを変更することで、より柔 
軟な設定ができます。

==== 表示に関するもの
デフォルトでは、天気データは、HTML_STARTとHTML_ENDに設定されている文字 
列で囲まれます。divやspanのクラスを変更する場合には、これらを変更するだ 
けで充分です。それ以上の変更が必要な場合は以下を変更してください。

: Weather.html_string
  @data[item]を参照して、天気を表示するHTML断片を作ってください。

: Weather.error_html_string
  データ取得エラーがあった場合に、@errorを参照してエラーを表示するHTML断
  片を作ってください。

携帯端末からの閲覧の際には、
  @options['weahter.show_mobile'] = true
の場合には、上記の代わりに、それぞれI_HTML_START、I_HTML_END、
Weather.i_html_stringが使われます。エラーの表示はできません。

==== 天気データの取得に関するもの
: Weather.parse_html( html, items )
  ((|html|))文字列を解析して、((|items|))ハッシュに従って@data[item]を定
  義してください。((|items|))には@optins['weather.items']または
  Weather_default_itemsが代入されます。返り値は利用されません。テーブル 
  を用いた天気情報源ならば、このメソッドをあまり改造しないで使えるかも 
  しれません。
   
==== 作成したメソッドのテスト
parse_htmlやhtml_stringのテストには以下のような方法が使えるかもしれませ 
ん。

まず、データ取得元から得られたHTMLをファイルに保存してください。それか 
ら、このファイルの最後の２行をコメントアウトしてtdiary.rb由来のメソッド 
を使わないようにして、以下のようなコードをこのファイルの最後に追加してコ
マンドラインからこのファイルを実行してみてください。

* parse_htmlをテストする場合
  HTMLをパースして得られたデータを表示します。
    html = File.open( 'weather_test.html' ) { |f| f.read }
    w = Weather.new
    w.parse_html( html, Weather_default_items )
    w.data.each do |item, value| puts "  #{item} => #{value}" end

* html_stringをテストする場合
  HTMLをパースして得られたデータをHTMLにして表示します。
    html = File.open( 'weather_test.html' ) { |f| f.read }
    w = Weather.new
    w.parse_html( html, Weather_default_items )
    puts w.html_string

== まだやるべきこと
* 天気に応じたアイコンの表示 -どうやろうか？

== 謝辞
その日の天気プラグインのアイディアを提供してくださったhsbtさん、実装のヒ
ントを提供してくださったzoeさんに感謝します。また、NOAAの情報を提供して
くださったkotakさんに感謝します。

The author appreciates National Weather Service
((<URL:http://weather.noaa.gov/>)) making such valuable data available
in public domain as described in ((<URL:http://www.noaa.gov/wx.html>)).

== Copyright
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.
=end

=begin ChangeLog
* Thu May  8, 2003 zunda <zunda at freeshell.org>
- A with B, observed,
* Mon May  5, 2003 zunda <zunda at freeshell.org>
- mobile agent
* Fri Mar 28, 2003 zunda <zunda at freeshell.org>
- overcast, Thanks kotak san.
* Fri Mar 21, 2003 zunda <zunda at freeshell.org>
- mist: kiri -> kasumi, Thanks kotak san.
* Sun Mar 16, 2003 zunda <zunda at freeshell.org>
- option weather.tz, appropriate handling of timezone
* Tue Mar 11, 2003 zunda <zunda at freeshell.org>
- records: windchill, winddir with 'direction variable', gusting wind
* Mon Mar 10, 2003 zunda <zunda at freeshell.org>
- WeatherTranslator module
* Sat Mar  8, 2003 zunda <zunda at freeshell.org>
- values with units
* Fri Mar  7, 2003 zunda <zunda at freeshell.org>
- edited to work with NOAA/NWS
* Fri Feb 28, 2003 zunda <zunda at freeshell.org>
- first draft
=end

require 'net/http'
Net::HTTP.version_1_1
require 'nkf'
require 'cgi'
require 'timeout'

=begin
== Classes and methods
=== WeatherTranslator module
We want Japanese displayed in a diary written in Japanese.

--- Weather::Words_ja
    Array of arrays of a Regexp and a Statement to be executed.
		WeatherTranslator::S.tr accepts this kind of hash to translate a
		given string.

--- WeatherTranslator::S < String
    Extension of String class. It translates itself.

--- WeatherTranslator::S.translate( table )
    Translates self according to ((|table|)).
=end

class Weather
	Words_ja = [
		[%r|\A(.*)/(.*)|, '"#{S.new( $1 ).translate( table )}/#{S.new( $2 ).translate( table )}"'],
		[%r|\s*\b(greater\|more) than (-?[\d.]+\s*\S*)\s*|i, '"#{S.new( $2 ).translate( table )}以上"'],
		[%r|^(.*?) with (.*)$|i, '"#{S.new( $2 ).translate( table )}ありの#{S.new( $1 ).translate( table )}"'],
		[%r|^(.*?) during the past hours?$|i, '"直前まで#{S.new( $1 ).translate( table )}"'],
		[%r|\s*\bdirection variable\b\s*|i, '"不定"'],
		[%r|\s*(-?[\d.]+)\s*\(?F\)?|, '"華氏#{$1}度"'],
		[%r|\s*\bmile(\(?s\)?)?\s*|i, '"マイル"'],
		[%r|\s*\b(mostly \|partly )clear\b\s*|i, '"晴"'],
		[%r|\s*\bclear\b\s*|i, '"快晴"'],
		[%r|\s*\b(mostly \|partly )?cloudy\b\s*|i, '"曇"'],
		[%r|\s*\bovercast\b\s*|i, '"曇"'],
		[%r|\s*\blight snow showers?\b\s*|i, '"にわか雪"'],
		[%r|\s*\blight snow\b\s*|i, '"小雪"'],
		[%r|\s*\blight drizzle\b\s*|i, '"小雨"'],
		[%r|\s*\blight rain showers?\b\s*|i, '"弱いにわか雨"'],
		[%r|\s*\bshowers?\b\s*|i, '"にわか雨"'],
		[%r|\s*\bdrizzle\b\s*|i, 'こぬか雨"'],
		[%r|\s*\blight rain\b\s*|i, '"霧雨"'],
		[%r|\s*\brain\b\s*|i, '"雨"'],
		[%r|\s*\bmist\b\s*|i, '"靄"'],
		[%r|\s*\bhaze\b\s*|i, '"霞"'],
		[%r|\s*\bfog\b\s*|i, '"霧"'],
		[%r|\s*\bsnow\b\s*|i, '"雪"'],
		[%r|\s*\bthunder( storm)?\b\s*|i, '"雷"'],
		[%r|\s*\bsand\b\s*|i, '"黄砂"'],
		[%r|\s*\bcumulonimbus clouds\b\s*|i, '"積乱雲"'],
		[%r|\s*\bobserved\b\s*|i, '""'],
		[%r|\s*\bC\b\s*|, '"℃"'],
	].freeze
end

module WeatherTranslator
	class S < String
		def translate( table )
			return '' if not self or self.empty?
			table.each do |x|
				if x[0] =~ self then
					return S.new( $` ).translate( table ) + eval( x[1] ) + S.new( $' ).translate( table )
				end
			end
			self
		end
	end
end

=begin
=== Weather class
Weather of a date.

--- Weather( date )
      A Weather is a weather datum for a ((|date|)) (a Time object).

--- Weather.get( url, header, items )
      Gets a WWW page from the ((|url|)) providing HTTP header in the
      ((|header|)) hash. The page is parsed calling Weahter.parse_html.
      Returns self.

--- Weather.parse_html( html, items )
      Parses an HTML page ((|html|)) and stores the data into @data
      according to ((|items|)).

--- Weather.to_s
      Creates a line to be stored into the cache file which will be
      parsed with Weather.parse method. Data are stored with the
      following sequence and separated with a tab:
        date(string), url, acquisition time(UNIX time) timezone, error (or empty string), item, value, ...
      Each record is terminated with a new line.

--- Weather.parse( string )
--- Weather::parse( string )
      Parses the ((|string|)) made by Weather.to_s and returns the
      resulting Weather.

--- Weather::date_to_s( date )
      Returns ((|date|)) formatted as a String used in to_s method. Used
      to find a record for the date from a file.

--- Weather.to_html( show_error = false )
      Returns an HTML fragment for the weather. When show_error is true,
      returns an error message as an HTML fragment in case an error
      occured when getting the weather.

--- Weather.to_i_html
      Returns a CHTML fragment for the weather.

--- Weather.html_string
--- Weather.error_html_string
      Returns an HTML fragment showing data or error, called from
      Weather.to_html.

--- Weather.i_html_string
      Returns a CHTML fragment to be shown on a mobile browser.
=end
class Weather
	attr_reader :date, :time, :url, :error, :data, :tz

	# magic numbers
	HTML_START = '<div class="weather"><span class="weather">'
	HTML_END = '</span></div>'
	I_HTML_START = '<P>'
	I_HTML_END = '</P>'
	WAITTIME = 10
	MAXREDIRECT = 10

	def error_html_string
		%Q|#{HTML_START}お天気エラー:<a href="#{@url}">#{CGI::escapeHTML( @error )}</a>#{HTML_END}|
	end

	# edit this method to define how you show the weather
	def html_string
		r = "#{HTML_START}"

		# time stamp
		if @tz then
		  tzbak = ENV['TZ']
			ENV['TZ'] = @tz	# this is not thread safe...
		end
		if @data['timestamp'] then
			r << Time::at( @data['timestamp'].to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		else
			r << Time::at( @time.to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		end
		r << '現在'
		if @tz then
		  ENV['TZ'] = tzbak
		end

		# weather
		r << %Q|<a href="#{@url}">|
		if @data['weather'] then
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['weather']).translate( Words_ja ))
		elsif @data['condition'] then
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['condition']).translate( Words_ja ))
		end

		# temperature
		if @data['temperature(C)'] and t = @data['temperature(C)'].scan(/-?[\d.]+/)[-1] then
		  r << %Q| #{sprintf( '%.0f', t )}℃|
		end

		r << "</a>#{HTML_END}\n"
	end


	# edit this method to define how you show the weather for a mobile agent
	def i_html_string
		r = ''

		# weather
		if @data['weather'] then
			r << "#{I_HTML_START}"
			r << %Q|<A HREF="#{@url}">|
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['weather']).translate( Words_ja ))
			r << "</A>#{I_HTML_END}\n"
		elsif @data['condition'] then
			r << "#{I_HTML_START}"
			r << %Q|<A HREF="#{@url}">|
			r << CGI::escapeHTML( WeatherTranslator::S.new( @data['condition']).translate( Words_ja ))
			r << "</A>#{I_HTML_END}\n"
		end

	end

	# edit this method according to the HTML we will get
	def parse_html( html, items )
		htmlitems = Hash.new

		# weather data is in the 4th table in the HTML from weather.noaa.gov
		table = html.scan( %r|<table.*?>(.*?)</table>|mi )[3][0]
		table.scan( %r|<tr.*?>(.*?)</tr>|mi ).collect {|a| a[0]}.each do |row|
			# <tr><td> *item* -> downcased </td><td> *value* </td></tr>
			if %r|<td.*?>(.*?)</td>\s*<td.*?>(.*?)</td>|mi =~ row then
				item = $1
				value = $2
				item = item.gsub( /<br>/i, '/' ).gsub( /<.*?>/m , '').strip.downcase
				value = value.gsub( /<br>/i, '/' ).gsub( /<.*?>/m , '').strip

				# unit conversion settings
				units = []
				case item
				when 'conditions at'
					# we have to convert the UTC time into UNIX time
					if /(\d{4}).(\d\d).(\d\d)\s*(\d\d)(\d\d)\s*UTC$/ =~ value then
						value = Time::utc( $1, $2, $3, $4, $5 ).to_i.to_s
					else
						raise StandardError, 'Parse error in "Conditions at"'
					end
				when 'visibility' # we want to preserve adjective phrase if possible
					if /(.*)([\d.]+)\s*mile(\(s\))?/i =~ value then
						htmlitems["#{item}(km)"] = sprintf( '%s %.3f', $1.strip, $2.to_f * 1.610 )
						htmlitems["#{item}(mile)"] = sprintf( '%s %s', $1.strip, $2 )
					end
				when 'wind' # we want to preserve adjective phrase if possible
					speed = value.scan( /([\d.]+)\s*MPH/i ).collect { |x| x[0] }
					htmlitems["#{item}(MPH)"] = speed.join(',')
					htmlitems["#{item}(m/s)"] = speed.collect {|s| sprintf( '%.4f', s.to_f * 0.4472222 ) }.join(',')
					if /([\d.]+)\s*degrees?/i =~ value then
						htmlitems["#{item}(deg)"] = $1
					end
					if /from\s+(the\s+)?(\w+)/i =~ value then
						htmlitems["#{item}dir"] = $2 + ($3 ? " #{$3}" : '')
					end
					if /(\(direction variable\))/i =~ value then
						htmlitems["#{item}dir"] << " #{$1}"
					end
				# just have to parse the value with the units
				when 'temperature'
					units = ['C', 'F']
				when 'windchill'
					units = ['C', 'F']
				when 'dew point'
					units = ['C', 'F']
				when 'relative humidity'
					units = ['%']
				when 'pressure (altimeter)'
					units = ['hPa']
				end

				# parse the value with the units if preferred and possible
				units.each do |unit|
					if /(-?[\d.]+)\s*\(?#{unit}\b/i =~ value then
						htmlitems["#{item}(#{unit})"] = $1
					end
				end

				# record the value as read from the HTML
				htmlitems[item] = value

			end	# if %r|<td.*?>(.*?)</td>\s*<td.*?>(.*?)</td>|mi =~ row
		end	# table.scan( %r|<tr.*?>(.*?)</tr>|mi ) ... do |row|

		# translate the parsed HTML into the Weather hash with more generic key
		items.each do |from, to|
		  if htmlitems[from] then
				# as specified in items
				@data[to] = htmlitems[from]
			elsif f = from.dup.sub!( /\([^)]+\)$/, '' ) \
					and htmlitems[f] \
					and t = to.dup.sub!( /\([^)]+\)$/, '' ) then
				# remove the units and try again if not found
				@data[t] = htmlitems[f]
			end
		end
	end

	def initialize( date = nil, tz = nil )
		@date = date or Time.now
	  @data = Hash.new
		@error = nil
		@url = nil
		@tz = tz || ENV['TZ']
	end

	def get( url, header = nil, items = {} )
		@url = url.gsub(/[\t\n]/, '')
		@error = nil
		@url =~ %r<http://([^/]+)(.*)>
		host = $1
		path = $2
		redirect = 0
		begin
			timeout( WAITTIME ) do
				begin
					d = ''
					Net::HTTP.start( host, 80 ) do |http|
						response , = http.get( path, header)
						d = NKF::nkf( '-e', response.body )
					end
					parse_html( d, items )
				rescue Net::ProtoRetriableError => err
					if m = %r<http://([^/]+)>.match( err.response['location'] ) then
						host = m[1].strip
						path = m.post_match
						redirect += 1
						retry if redirect < MAXREDIRECT
						raise StandardError, 'Too many redirections'
					end
					raise StandardError, 'Error in redirection'
				end
			end
		rescue TimeoutError
			@error = 'Timeout'
		rescue
			@error = NKF::nkf( '-e', $!.message.gsub( /[\t\n]/, ' ' ) )
		end
		@time = Time::now
		self
	end

	def to_s
	  tzstr = @tz ? " #{tz}" : ''
		r = "#{Weather::date_to_s( @date )}\t#{@url}\t#{@time.to_i}#{tzstr}\t#{@error}"
		@data.each do |item, value|
			r << "\t#{item}\t#{value}" if value and not value.empty?
		end
		r << "\n"
	end

	def parse( string )
		i = string.chomp.split( /\t/ )
		y, m, d = i.shift.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0]
		@date = Time::local( y, m, d )
		@url = i.shift
		itime, @tz = i.shift.split( / +/, 2 )
		@time = Time::at( itime.to_i )
		error = i.shift
		if error and not error.empty? then
			@error = error
		else
			@error = nil
		end
		@data.clear
		while not i.empty? do
			@data[i.shift] = i.shift
		end
		self
	end

	def to_html( show_error = false )
		@error ? (show_error ? error_html_string : '') : html_string
	end

	def to_i_html
		@error ? '' : i_html_string
	end

	def store( path, date )
		ddir = File.dirname( Weather::file_path( path, date ) )
		# mkdir_p logic copied from fileutils.rb
		# Copyright (c) 2000,2001 Minero Aoki <aamine@loveruby.net>
		# and edited (zunda.freeshell.org does not have fileutils.rb T_T
		dirstack = []
		until FileTest.directory?( ddir ) do
			dirstack.push( ddir )
			ddir = File.dirname( ddir )
		end
		dirstack.reverse_each do |dir|
			Dir.mkdir dir
		end
		# finally we can write a file
		File::open( Weather::file_path( path, date ), 'a' ) do |fh|
			fh.puts( to_s )
		end
	end

	class << self
		def parse( string )
			new.parse( string )
		end

		def date_to_s( date )
			date.strftime( '%Y%m%d' )
		end

		def file_path( path, date )
			date.strftime( "#{path}/%Y/%Y%m.weather" ).gsub( /\/\/+/, '/' )
		end

		def restore( path, date )
			r = nil
			datestring = Weather::date_to_s( date )
			begin
				File::open( file_path( path, date ), 'r' ) do |fh|
					fh.each( "\n" ) do |l|
						if /^#{datestring}\t/ =~ l then
							r = l # will use the last/newest data found in the file
						end
					end
				end
			rescue Errno::ENOENT
			end
			r ? Weather::parse( r ) : nil
		end

	end
end

=begin
=== Methods as a plugin
weather method also can be used as a usual plug-in in your diary body.
Please note that the argument is not a String but a Time object.

--- weather( date = nil )
      Returns an HTML flagment of the weather for the date. This will be
      provoked as a body_enter_proc. @date is used when ((|date|)) is
      nil.

--- get_weather
      Access the URL to get the current weather information when:
      * @mode is append or replace,
      * @date is today, and
      * There is no cached data without an error for today
      This will be provoked as an update_proc.
=end

Weather_default_path = "#{@cache_path}/weather"
Weather_default_items = {
	# UNIX time
	'conditions at'             => 'timestamp',
	# English phrases
	'sky conditions'            => 'condition',
	'weather'                   => 'weather',
	# Direction (e.g. SE)
	'winddir'                   => 'winddir',
	# English phrases when unit conversion failed, otherwise, key with (unit)
	'wind(m/s)'                 => 'wind(m/s)',
	'wind(deg)'                 => 'wind(deg)',
	'visibility(km)'            => 'visibility(km)',
	'temperature(C)'            => 'temperature(C)',
	'windchill(C)'              => 'windchill(C)',
	'dew point(C)'              => 'dewpoint(C)',
	'relative humidity(%)'      => 'humidity(%)',
	'pressure (altimeter)(hPa)' => 'pressure(hPa)',
}

def weather( date = nil )
	path = @options['weather.dir'] || Weather_default_path
	w = Weather::restore( path, date || @date )
	if w then
		unless @cgi.mobile_agent? then
			w.to_html( @options['weahter.show_error'] )
		else
			w.to_i_html if @options['weahter.show_mobile']
		end
	else
		''
	end
end

def get_weather
	return unless @options['weather.url']
	return unless @mode == 'append' or @mode == 'replace'
	return unless @date.strftime( '%Y%m%d' ) == Time::now.strftime( '%Y%m%d' )
	path = @options['weather.dir'] || Weather_default_path
	w = Weather::restore( path, @date )
	if not w or w.error then
		items = @options['weather.items'] || Weather_default_items
		w = Weather.new( @date, @options['weather.tz'] )
		w.get( @options['weather.url'], @options['weather.header'], items )
		w.store( path, @date )
	end
end

# register to tDiary
add_body_enter_proc do |date| weather( date ) end
add_update_proc do get_weather end
