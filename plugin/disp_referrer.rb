=begin
= 本日のリンク元もうちょっとだけ強化プラグイン((-$Id: disp_referrer.rb,v 1.31 2003-09-30 15:49:28 zunda Exp $-))

== 概要
アンテナからのリンク、サーチエンジンの検索結果を、通常のリンク元の下にま
とめて表示します。サーチエンジンの検索結果は、検索語毎にまとめられます。

最新の日記の表示では、通常のリンク元以外のリンク元を隠します。

== 注意
以前の版(1.1.2.39以前)からコードのほとんどを実装しなおしたため、
* 検索エンジンに関する動作が違う
* 廃止されたオプションがある
* オプション名が変更された
という非互換があります。基本的な設定はWWWブラウザからできるようになって
いますので、我慢してください。すみません。

以前の版に比べると、
* キャッシュにより表示が高速化された((-手元では、キャッシュを使わない場
  合にくらべて、1日分で2/3ほど、最新3日分で1/2ほどの実時間で日記が生成
  されました-))。この機能は残念ながら、レンタル日記などsecure=trueな日記
  では使えません。
* リンク元置換リストにないURLを比較的簡単にWWWブラウザからリストに追加で
  きるようになった
* 置換後の文字列の最初に[]で囲まれた文字を入れることによって、ユーザー
  がカテゴリーを増設できるようになった。((-tDiary本体とは違い、１つの
  URLは１つのカテゴリーしか持てないことにご注意ください。-))
* 基本的な設定をWWWブラウザからできるようになった
* disp_referrer.rbが無くても使える
* UconvライブラリやNoraライブラリがあればあるなりに、無ければないなりに
  動作する
という利点があります。

== 使い方
このプラグインをインストールすることで、デフォルトでは、
* 一日分の日記の表示で、「本日のリンク元」がアンテナ、検索エンジン、その
  他にまとめて表示されるようになります。置換後の文字列の最後の()を除いた
  タイトルでグループします。また、検索エンジンからのリンクは、キーワード
  別にまとめられます。
* 最新の日記の表示で、「本日のリンク元」にアンテナや検索エンジンからのリ
  ンクが表示されなくなります。
リンク元URLのタイトルへの置換は、tDiary本体のリンク元置換リストを使いま
す。

オプションについては下記をご覧ください。基本的なオプションは、tDiaryの設
定画面から、「リンク元もうちょっと強化」をクリックすることで設定できます。
初めて設定する時には、
  Insecure: can't modify hash (SecurityError)
というエラーが出る可能性があります。これはtDiaryの問題です。この場合には、
tDiaryを新しくして1.5.5.20030806以降を使うか、「基本」から何も変更せず 
に「OK」を押すことでエラーを回避できるでしょう。

リンク元置換リストやオプションを変更した場合は、キャッシュディレクトリ
にあるキャッシュファイルdisp_referrer2.cacheやdisp_referrer2.cache~をプ
ラグインの設定画面から更新する必要があります。このプラグインの設定画面か
ら変更した項目については、変更時にキャッシュの更新もします。

リンク元は、以下のような基準で分類されます。

: 通常のリンク元(「本日のリンク元」)
  リンク元置換リストにあてはまるURLのうち、下記以外のもの。
  @options['disp_referrer2.unknown.divide']=falseの場合は、リンク元置換
  リストにあてはまらないURLもここに含まれます。

  さらに、リンク元置換リストによって置換された後の文字列の最初に[]で囲ま
  れた文字列がある場合は、これをカテゴリーと解釈してカテゴリー別に表示を
  分けます。この機能を抑制するには、WWWブラウザから設定画面を利用するか、
  tdiary.confで@options['disp_referrer2.normal.categorize']=falseにして
  ください。このオプションを変更した場合にはキャッシュを更新する必要があ
  ります。

: アンテナ
  URLに /a/ antenna/ antenna. などの文字列が含まれるか、置換後の文字列に、
  アンテナ links などの文字列が含まれるリンク元です。これらの条件は、
  @options['disp_referrer2.antenna.url']や
  @options['disp_referrer2.antenna.title']によって変更できます。
  tdiary.confを編集してください。キャッシュを更新する必要があります。

: その他
  リンク元置換リストになかったURLです。あまり長いURLは、tDiary本体の置換
  リストによって通常のリンク元に分類されてしまう可能性があります。

: 検索
  このプラグインに含まれる検索エンジンのリストに一致したURLです。リスト
  はDispRef2Setup::Enginesにあります。うまく検索エンジンと認識されない
  URLは、ほとんどの場合、通常のリンク元に混ざって表示されてしまうでしょ
  う。このような場合は、URLを
  ((<URL:http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?disp_referrer2.rb>))
  に知らせていただけると作者が喜びます。

=== 環境
ruby-1.6.7と1.8.0で動作を確認しています。これ以外のバージョンのRubyでも
動作するかもしれません。

tdiary-1.5.3-20030509以降で使えます。これ以前のtDiary-1.5では、
00default.rbにbot?メソッドが定義されていないため、検索エンジンのクロール
に対してリンク元が表示されてしまいます。

secureモードでも使えますがキャッシュによる高速化ができません。

mod_rubyでの動作は今のところ確認していません。

=== インストール方法
このファイルをtDiaryのpluginディレクトリ内にコピーしてください。このプラ
グインの最新版は、
((<URL:http://zunda.freeshell.org/d/plugin/disp_referrer2.rb>))
にあるはずです。

また、Noraライブラリがインストールされている場合には、URLの解釈やHTMLの
エスケープに、Rubyに標準添付のCGIライブラリの代わりにNoraライブラリを使
用します。これにより、処理速度が若干速くなります((-手元で試したところ、
一日分の表示にかかる時間が1割程度短かくなりました。-))。Noraについての詳
細は、((<URL:http://raa.ruby-lang.org/list.rhtml?name=Nora>))を参照して
ください。

=== オプション
この日記で設定できるオプションの一覧は、DispRef2Setup::Defaultsにありま
す。これらのオプションのkeyの最初に、「disp_referrer2.」を追加すること
で、tdiary.confの@optionsのkeyとなり、tdiary.confから設定できるようにな
ります。これらのオプションのうち、DispRef2URL::Cached_optionsに挙げられ
ているものは、変更の際にキャッシュの更新が必要です。

また、tDiaryの設定画面から「リンク元もうちょっと強化」を選ぶことでWWWブ
ラウザから設定できる項目もあります。

== 謝辞
このプラグインは、
* UTF-8文字列のEUC文字列への変換機能
* 一部の検索エンジン名とそのURL
* 検索エンジンのロボットのクローリングの際にリンク元を表示しない機能
を、MUTOH Masaoさんのdisp_referrer.rbからコピー、編集して使わせていただ
いています。(検索エンジンのロボットに関する機能は現在はtDiary本体にとり
こまれています。)

また、URLを解釈する機能の一部を、Rubyに付属のcgi.rbからコピー、編集して
使わせていただいています。

さらに、通常のリンク元を[]で囲まれた文字列を使ってカテゴリ分けするアイデ
ィアは、kazuhikoさんのものです。

皆様に感謝いたします。

== Todos
* secure=trueでリンク元置換リストのテキストフィールドでリターンを押した際の動作
* parse_as_search高速化: hostnameのキャッシュ？

== 著作権について
Copyright (C) 2003 zunda <zunda at freeshell.org>

Please note that some methods in this plugin are written by other
authors as written in the comments.

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

=begin ChangeLog
* Mon Sep 29, 2003 zunda <zunda at freeshell.org>
- forgot to change arguments after changing initialize()
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- name.untaint to eval name
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- use to_native instead of to_euc
* Mon Sep 19, 2003 zunda <zunda at freeshell.org>
- disp_referrer2.rb,v 1.1.2.104 commited as disp_referrer.rb
* Mon Sep  1, 2003 zunda <zunda at freeshell.org>
- more strcit check for infoseek search enigne
* Wed Aug 27, 2003 zunda <zunda at freeshell.org>
- rd.yahoo, Searchalot, Hotbot added
* Tue Aug 12, 2003 zunda <zunda at freeshell.org>
- search engine list cleaned up
* Mon Aug 11, 2003 zunda <zunda at freeshell.org>
- instance_eval for e[2] in the search engine list
* Wed Aug  7, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - キャッシュの更新をより確実にするようにしました。WWWブラウザから置換
    リストを作った場合にはリストの最初に追加されます。
  - secure=trueな日記でその他のリンク元リストが表示できるようになりました。
- Regexp generation for Wiki sites
* Wed Aug  6, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - 主なオプションとリンク元置換リストの効率的な編集がWWWブラウザからで
    きるようになりました。secure=trueな日記では一部の機能は使えません。
* Sat Aug  2, 2003 zunda <zunda at freeshell.org>
- Second version
- basic functions re-implemented
  - オプションを命名しなおしました。また不要なオプションを消しました。
    tdiary.confを編集していた方は、お手数ですが設定をしなおしてください。
  - Noraライブラリとキャッシュの利用で高速化しました。
  - 検索エンジンのリストをプラグインで持つようになりました。&や;を含む検
    索文字列も期待通りに抽出できます。
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- First version
=end

=begin
== このプラグインで定義されるクラスとメソッド
=== Array
Array#values_at()が無い場合、追加します。
=end
# 1.8 feature
unless [].respond_to?( 'values_at' ) then
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
		class Array
			alias values_at indices
		end
	MODIFY_CLASS
end

# to be visible from inside classes
Dispref2plugin = self
Dispref2plugin_cache_path = @cache_path
Dispref2plugin_secure = @conf.secure

# cache format
Root_DispRef2URL = 'dispref2url' # root for DispRef2URLs

=begin
=== Tdiary::Plugin::DispRef2DummyPStore
PStoreと同じメソッドを提供しますがなにもしません。db[key]は全てnilを返す
ことに注意してください。
=end
# dummy PStore
class DispRef2DummyPStore
	def initialize( file )
	end
	def transaction( read_only = false )
		yield
	end
	def method_missing( name, *args )
		nil
	end
end

=begin
=== Tdiary::Plugin::DispRef2PStore
@secure=falseな日記ではPStoreと同等のメソッドを、@secure=trueな日記では
何もしないメソッドを提供します。

--- DispRef2PSTore#transaction( read_only = false )
     Ruby-1.7以降の場合は読み込み専用に開くこともできます。Ruby-1.6の場
     合はread_only = trueでも読み書き用に開きます。

--- DispRef2PSTore#real?
      本物のPSToreが使える時はtrue、そうでない時はfalseを返します。
=end
unless @conf and @conf.secure then
	require 'pstore'
	class DispRef2PStore < PStore
		def real?
			true
		end
		def transaction( read_only = false )
			begin
				super
			rescue ArgumentError
				super()
			end
		end
	end
else
	class DispRef2PStore < DispRef2DummyPStore
		def real?
			false
		end
	end
end

=begin
=== Tdiary::Plugin::DispRef2String
文字コードの変換、URL、HTMLでの取り扱いに関するメソッド群です。インスタ
ンスは作りません。UconvライブラリやNoraライブラリがあればそれを使い、無
ければ無いなりに処理します。

--- DispRef2String::nora?
      Noraが使える時にはtrue、そうでないときにはfalseを返します。

--- DispRef2String::normalize( str )
      続く空白を取り去ったりsite:...という文字列を消したりして、検索キー
      ワードを規格化します。

--- DispRef2String::parse_query( str )
      URLに含まれるquery部(key=value&...)を解析し、結果をkeyをキー、
      valueの配列を値としたハッシュとして返します。値のアンエスケープは
      しません。valueが無かった場合は空文字列が設定されます。

--- DispRef2String::separate_query( str )
      URLをquery部より前と後に分けて配列として返します。query部が無い場
      合はnilを返します。

--- DispRef2String::hostname( str )
      URLに含まれるホスト名あるいはIPアドレスを返します。ホスト名がみつ
      からない場合は、((|str|))を返します。

--- DispRef2String::company_name( str, hash_list )
      URLより、googleやbiglobeといった名前のうち((|hash_list|))のkeyに含
      まれるものを返します。みつからない場合は、nilを返します。

--- DispRef2String::escapeHTML( str )
      HTMLに含まれても安全なようにエスケープします。

--- DispRef2String::unescape( str )
      URLをアンエスケープします。

--- DispRef2String::bytes( size )
      バイト単位の大きさをMB KB Bの適切な単位に変換します。

--- DispRef2String::comma( integer )
      数字をカンマで3桁ずつに分けます。

--- DispRef2String::url_regexp( url )
      ((|url|))から置換リスト用の正規表現文字列をつくります。

--- DispRef2String::url_match?( url, list )
      ((|url|))が((|list|))のどれかにマッチするかどうか調べます。

=end
# string handling
class DispRef2String

	# strips site:... portion (google), multiple spaces, and start/end spaces
	def self::normalize( str )
		str.sub( /\bsite:(\w+\.)*\w+\b/, '' ).gsub( /[　\s\n]+/, ' ' ).strip
	end

	# parse_query parses the not unescaped query in a URL
	# copied from from CGI::parse in cgi.rb by
	#   Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
	#   Copyright (C) 2000  Information-technology Promotion Agency, Japan
	#   Wakou Aoyama <wakou@ruby-lang.org>
	# eand edited
	def self::parse_query( str )
		params = Hash.new
		str.split( /[&;]/n ).each do |pair|
			k, v = pair.split( '=', 2 )
			( params[k] ||= Array.new ) << ( v ? v : '' )
		end
		params
	end

	# separate the query part (or nil) from a URL
	def self::separate_query( str )
		base, query = str.split( /\?/, 2 )
		if query then
			[ base, query ]
		else
			[ base, nil ]
		end
	end

	# get the host name (or nil) from a URL
	@@hostname_match = %r!https?://([^/]+)/?!
	def self::hostname( str )
		@@hostname_match =~ str ? $1 : str
	end

	# get the `company name' included in keys of hash_table (or nil) from a URL
	def self::company_name( str, hash_table )
		hostname( str ).split( /\./ ).values_at( -2, -3, 0 ).each do |s|
			return s if s and hash_table.has_key?( s.downcase )
		end
		nil
	end

	# escapeHTML: escape to be used in HTML
	# unescape: unesape the URL
	@@have_nora = false
	begin
		begin
			require 'web/escape'
			@@have_nora = true
		rescue LoadError
			require 'escape'
			@@have_nora = true
		end
		def self::escapeHTML( str )
			Web::escapeHTML( str )
		end
		def self::unescape( str )
			Web::unescape( str )
		end
	rescue LoadError
		def self::escapeHTML( str )
			CGI::escapeHTML( str )
		end
		def self::unescape( str )
			CGI::unescape( str )
		end
	end

	# Nora?
	def self::nora?
		@@have_nora
	end

	# add K, M with 1024 divisions
	def self::bytes( size )
		s = size.to_f
		t = s / 1024.0
		return( '%.0f' % s ) if t < 1
		s = t
		t = s / 1024.0
		return( '%.1fK' % s ) if t < 1
		return( '%.1fM' % t )
	end

	# insert comma
	def self::comma( integer )
		integer.to_s.reverse.scan(/.{1,3}/).join(',').reverse
		# [ruby-list:30144]
	end

	# make up a regexp from a url
	def self::url_regexp( url )
		r = url.dup
		r.sub!( /\/\d{4,8}\.html$/, '/' )	# from a tDiary?
		r.sub!( /\/(index\.(rb|cgi))?\?date=\d{4,8}$/, '/' )	# from a tDiary?
		r.gsub!( /\./, '\\.' )	# dots in the FQDN
		unless /(w|h)iki/i =~ r then
			r.sub!( /\?.*/, '.*' )
		else
			r.sub!( /\?.*/, '\?(.*)' )
		end
		r.sub!( /\/(index\.html?)$/, '/' )	# directory index
		r.sub!( /\/$/, '/?.*' )	# may be also from a lower level
		"^#{r}"	# always good to put a ^
	end

	# matchs to the regexp strings?
	def self::url_match?( url, list )
		list = list.split( /\n/ ) if String == list.class
		list.each do |entry|
			entry = entry[0] if Array == entry.class
			return true if /#{entry}/i =~ url
		end
		false
	end

end

=begin
=== Tdiary::Plugin::DispRef2Setup
プラグインの動作を決めるパラメータを設定します。

--- DispRef2Setup::Last_parenthesis
      文字列の最後の()の中身が$1に設定される正規表現です。

--- DispRef2Setup::First_bracket
      文字列の最初の[]の中身が$1に、その後の文字列が$2に設定される正規表
      現です。

--- DispRef2Setup::Engines
      検索エンジンからのキーワードの取得方法のハッシュです。keyには
      googleやyahooといった、検索エンジンのURLの一部(ピリオドで区切った
      ものの、最後から2番目と3番目、最初のものと一致を試します)を小文字
      で指定します。値は、その検索エンジンの置換用の正規表現と置換後の
      文字列、検索キーワードを含むURLのパラメータ名(あるいはquery文字列
      をレシーバとしてinstance_evalされ、キーワードとキャッシュのURLある
      いはnilを返すコード)、キャッシュ元のURL をとりだす正規表現を、この
      順番で配列にしたものの、配列です。詳細はソースを参照してください。

--- DispRef2Setup::Defaults
      オプションのデフォルト値です。tDiary本体から@optionsで設定するには、
      このハッシュのkeyの前に「disp_referrer2.」をつけたkeyを使ってくだ
      さい。オプションの詳細はソースのコメントを参照してください。

--- DispRef2Setup::new( conf, limit = 100, is_long = true )
      ((|conf|))にはtDiaryの@confを、((|limit|))には一項目あたりの表示リ
      ンク元数を、((|is_long|))は一日分の表示の場合にはtrueを、最新の表
      示の場合にはfalseを設定してください。

--- DispRef2Setup#update!
      tDiaryの@optionsにより自身を更新します。

--- DispRef2Setup#is_long
--- DispRef2Setup#referer_table
--- DispRef2Setup#no_referer
--- DispRef2Setup#secure
      それぞれ、一日分の表示かどうか、tDiaryの置換テーブル、tDiaryのリン
      ク元除外リスト、日記のセキュリティ設定を返します。

--- DIspRef2Setup#to_native( str )
      tDiaryの言語リソースで定義されている文字コードを正規化するメソッド
      です。

--- DispRef2Setup#[]
      設定されている値を返します。
=end
# configuration of this plugin
class DispRef2Setup < Hash
	# useful regexps
	Last_parenthesis = /\((.*?)\)\Z/m
	First_bracket = /\A\[(.*?)\](.+)/m
	Google_cache = /cache:[^:]+:([^+]+)+/

	# Hash table of search engines
	# key: company name
	# value: array of:
	# [0]:url regexp [1]:title [2]:keys for search keyword [3]:cache regexp
	Engines = {
		'google' => [
			[%r{^http://.*?\bgoogle\.([^/]+)/(search|custom|ie)}i, '".#{$1}のGoogle検索"', ['as_q', 'q', 'as_epq'], Google_cache],
			[%r{^http://.*?\bgoogle\.([^/]+)/.*url}i, '".#{$1}のGoogleのURL検索?"', ['as_q', 'q'], Google_cache],
			[%r{^http://.*?\bgoogle/search}i, '"たぶんGoogle検索"', ['as_q', 'q'], Google_cache],
			[%r{^http://eval.google\.([^/]+)}i, '".#{$1}のGoogle Accounts"', [], nil],
			[%r{^http://.*?\bgoogle\.([^/]+)}i, '".#{$1}のGoogle検索"', [], nil],
		],
		'yahoo' => [
			[%r{^http://.*?\.rd\.yahoo\.([^/]+)}i, '".#{$1}のYahooのリダイレクタ"', 'split(/\*/)[1]', nil],
			[%r{^http://.*?\.yahoo\.([^/]+)}i, '".#{$1}のYahoo!検索"', ['p', 'va', 'vp'], Google_cache],
		],
		'netscape' => [[%r{^http://.*?\.netscape\.([^/]+)}i, '".#{$1}のNetscape検索"', ['search', 'query'], Google_cache]],
		'msn' => [[%r{^http://.*?\.MSN\.([^/]+)}i, '".#{$1}のMSNサーチ"', ['q', 'MT'], nil ]],
		'metacrawler' => [[%r{^http://.*?.metacrawler.com}i, '"MetaCrawler"', ['q'], nil ]],
		'metabot' => [[%r{^http://.*?\.metabot\.ru}i, '"MetaBot.ru"', ['st'], nil ]],
		'altavista' => [[%r{^http://.*?\.altavista\.([^/]+)}i, '".#{$1}のAltaVista検索"', ['q'], nil ]],
		'infoseek' => [[%r{^http://(www\.)?infoseek\.co\.jp}i, '"インフォシーク"', ['qt'], nil ]],
		'odn' => [[%r{^http://.*?\.odn\.ne\.jp}i, '"ODN検索"', ['QueryString', 'key'], nil ]],
		'lycos' => [[%r{^http://.*?\.lycos\.([^/]+)}i, '".#{$1}のLycos"', ['query', 'q', 'qt'], nil ]],
		'fresheye' => [[%r{^http://.*?\.fresheye}i, '"フレッシュアイ"', ['kw'], nil ]],
		'goo' => [
			[%r{^http://.*?\.goo\.ne\.jp}i, '"goo"', ['MT'], nil ],
			[%r{^http://.*?\.goo\.ne\.jp}i, '"goo"', [], nil ],
		],
		'nifty' => [
			[%r{^http://.*?\.nifty\.com}i, '"@nifty/@search"', ['q', 'Text'], Google_cache],
			[%r{^http://.*?\.nifty\.com}i, '"@niftyのリダイレクタ"', ['title'], nil ],
		],
		'eniro' => [[%r{^http://.*?\.eniro\.se}i, '"Eniro"', ['q'], Google_cache]],
		'excite' => [[%r{^http://.*?\.excite\.([^/]+)}i, '".#{$1}のExcite"', ['search', 's', 'query', 'qkw'], nil ]],
		'biglobe' => [
			[%r{^http://.*?search\.biglobe\.ne\.jp}i, '"BIGLOBEサーチ"', ['q'], nil ],
			[%r{^http://.*?search\.biglobe\.ne\.jp}i, '"BIGLOBEサーチ"', [], nil ],
		],
		'dion' => [[%r{^http://dir\.dion\.ne\.jp}i, '"Dion"', ['QueryString', 'key'], nil ]],
		'naver' => [[%r{^http://.*?\.naver\.co\.jp}i, '"NAVER Japan"', ['query'], nil ]],
		'webcrawler' => [[%r{^http://.*?\.webcrawler\.com}i, '"WebCrawler"', ['qkw'], nil ]],
		'euroseek' => [[%r{^http://.*?\.euroseek\.com}i, '"Euroseek.com"', ['string'], nil ]],
		'aol' => [[%r{^http://.*?\.aol\.}i, '"AOLサーチ"', ['query'], nil ]],
		'alltheweb' => [
			[%r{^http://.*?\.alltheweb\.com}i, '"AlltheWeb.com"', ['q'], nil ],
			[%r{^http://.*?\.alltheweb\.com}i, '"AlltheWeb.com"', [], nil ],
		],
		'kobe-u' => [
			[%r{^http://bach\.scitec\.kobe-u\.ac\.jp/cgi-bin/metcha.cgi}i, '"メッチャ検索エンジン"', ['q'], nil ],
			[%r{^http://bach\.istc\.kobe-u\.ac\.jp/cgi-bin/metcha.cgi}i, '"メッチャ検索エンジン"', ['q'], nil ],
		],
		'tocc' => [[%r{^http://www\.tocc\.co\.jp/search/}i, '"TOCC/Search"', ['QRY'], nil ]],
		'yappo' => [[%r{^http://i\.yappo\.jp/}i, '"iYappo"', [], nil ]],
		'suomi24' => [[%r{^http://.*?\.suomi24\.([^/]+)/.*query}i, '"Suomi24"', ['q'], Google_cache]],
		'earthlink' => [[%r{^http://search\.earthlink\.net/search}i, '"EarthLink Search"', ['as_q', 'q', 'query'], Google_cache]],
		'infobee' => [[%r{^http://infobee\.ne\.jp/}i, '"新鮮情報検索"', ['MT'], nil ]],
		't-online' => [[%r{^http://brisbane\.t-online\.de/}i, '"T-Online"', ['q'], Google_cache]],
		'walla' => [[%r{^http://find\.walla\.co\.il/}i, '"Walla! Channels"', ['q'], nil ]],
		'mysearch' => [[%r{^http://.*?\.mysearch\.com/}i, '"My Search"', ['searchfor'], nil ]],
		'jword' => [[%r{^http://search\.jword.jp/}i, '"JWord"', ['name'], nil ]],
		'nytimes' => [[%r{^http://query\.nytimes\.com/search}i, '"New York Times: Search"', ['as_q', 'q', 'query'], Google_cache]],
		'aaacafe' => [[%r{^http://search\.aaacafe\.ne\.jp/search}i, '"AAA!CAFE"', ['key'], nil]],
		'virgilio' => [[%r{^http://search\.virgilio\.it/search}i, '"VIRGILIO Ricerca"', ['qs'], nil]],
		'ceek' => [[%r{^http://www\.ceek\.jp}i, '"ceek.jp"', ['q'], nil]],
		'cnn' => [[%r{^http://websearch\.cnn\.com}i, '"CNN.com"', ['query', 'as_q', 'q', 'as_epq'], Google_cache]],
		'webferret' => [[%r{^http://webferret\.search\.com}i, '"WebFerret"', 'split(/,/)[1]', nil]],
		'eniro' => [[%r{^http://www\.eniro\.se}i, '"Eniro"', ['query', 'as_q', 'q'], Google_cache]],
		'passagen' => [[%r{^http://search\.evreka\.passagen\.se}i, '"Eniro"', ['q', 'as_q', 'query'], Google_cache]],
		'redbox' => [[%r{^http://www\.redbox\.cz}i, '"RedBox"', ['srch'], nil]],
		'odin' => [[%r{^http://odin\.ingrid\.org}i, '"ODiN検索"', ['key'], nil]],
		'kensaku' => [[%r{^http://www\.kensaku\.}i, '"kensaku.jp検索"', ['key'], nil]],
		'hotbot' => [[%r{^http://www\.hotbot\.}i, '"HotBot Web Search"', ['MT'], nil ]],
		'searchalot' => [[%r{^http://www\.searchalot\.}i, '"Searchalot"', ['q'], nil ]],
		'www' => [[%r{^http://www\.google/search}i, '"Google検索?"', ['as_q', 'q'], Google_cache]],	# TLD missing
		'planet' => [[%r{^http://www\.planet\.nl/planet/}i, '"Planet-Zoekpagina"', ['googleq', 'keyword'], Google_cache]], # googleq parameter has a strange prefix
		'216' => [[%r{^http://(\d+\.){3}\d+/search}i, '"Google検索?"', ['as_q', 'q'], Google_cache]],	# cache servers of google?
	}

	# default options
	Defaults = {
		'long.only_normal' => false,
			# trueの場合、一日分の表示で、通常のリンク元以外を隠します。
		'short.only_normal' => true,
			# trueの場合、最新の表示で、通常のリンク元以外を隠します。
			# falseの場合は、プラグインの無い場合と全くおなじ表示になります。
		'antenna.url' => '(\/a\/|(?!.*\/diary\/)antenna[\/\.]|\/tama\/|www\.tdiary\.net\/?(i\/)?(\?|$)|links?|kitaj\.no-ip\.com\/iraira\/)',
			# アンテナのURLに一致する正規表現の文字列です。
		'antenna.title' => '(アンテナ|links?|あんてな)',
			# アンテナの置換後の文字列に一致する正規表現の文字列です。
		'normal.label' => Dispref2plugin.referer_today,
			# 通常のリンク元のタイトルです。デフォルトでは、「本日のリンク元」です。
		'antenna.label' => 'アンテナ',
			# アンテナのリンク元のタイトルです。
		'unknown.label' => 'その他',
			# その他のリンク元のタイトルです。
		'unknown.hide' => false,
			# trueの場合はリンク元置換リストにないURLは表示しません
		'search.label' => '検索',
			# 検索エンジンからのリンク元のタイトルです。
		'unknown.divide' => true,
			# trueの場合、置換リストに無いURLを通常のリンク元と分けて表示します。
			# falseの場合、置換リストに無いURLを通常のリンク元と混ぜて表示します。
		'normal.group' => true,
			# trueの場合、置換後の文字列で通常のリンク元をグループします。
			# falseの場合、URL毎に別のリンク元として表示します。
		'normal.categorize' => true,
			# trueの場合、置換後の文字列の最初の[]の文字列でカテゴリー分けします。
		'normal.ignore_parenthesis' => true,
			# trueの場合、グループする際に置換後の文字列の最後の()を無視します。
		'antenna.group' => true,
			# trueの場合、置換後の文字列で通常のリンク元をグループします。
			# falseの場合、URL毎に別のリンク元として表示します。
		'antenna.ignore_parenthesis' => true,
			# trueの場合、グループする際に置換後の文字列の最後の()を無視します。
		'search.expand' => false,
			# trueの場合、検索キーワードとともに検索エンジン名を表示します。
			# falseの場合、回数のみを表示します。
		'search.unknown_keyword' => 'キーワード不明',
			# キーワードがわからない検索エンジンからのリンクに使う文字列です。
		'search_engines' => Engines,
			# 検索エンジンのハッシュです。
		'cache_label' => '(%sのキャッシュ)',
			# 検索エンジンのキャッシュのURLを表示する文字列です。
		'cache_path' => "#{Dispref2plugin_cache_path}/disp_referrer2.cache",
			# このプラグインで使うキャッシュファイルのパスです。
		'no_cache' => false,
			# trueの場合、@secure=falseな日記でもキャッシュを使いません。
		'normal-unknown.title' => '\Ahttps?:\/\/',
			# 置換された「その他」のリンク元のタイトル、あるいは置換されていな
			# いリンク元のタイトルにマッチします。
		'configure.use_link' => true,
			# リンク元置換リストの編集画面で、リンク元へのリンクを作ります。
		'reflist.ignore_urls' => '',
			# 置換リストのリストアップの際に無視するURLの正規表現の文字列
			# \n区切で並べます
	}

	attr_reader :is_long, :referer_table, :no_referer, :secure

	def initialize( conf, limit = 100, is_long = true )
		super()
		@conf = conf

		# mode
		@is_long = is_long
		@limit = limit
		@options = conf.options

		# URL tables
		@referer_table = conf.referer_table
		@no_referer = conf.no_referer

		# security
		@secure = Dispref2plugin_secure

		# options from tDiary
		update!
	end

	def to_native( str )
		@conf.to_native( str )
	end

	# options from tDiary
	def update!
		# defaults
		self.replace( DispRef2Setup::Defaults.dup )

		# from tDiary
		self.each_key do |key|
			options_key = "disp_referrer2.#{key}"
			self[key] = @options[options_key] if @options.has_key?( options_key )
		end

		# additions
		self['labels'] = {
			DispRef2URL::Normal => self['normal.label'],
			DispRef2URL::Antenna => self['antenna.label'],
			DispRef2URL::Search => self['search.label'],
			DispRef2URL::Unknown => self['unknown.label'],
		}
		self['antenna.url.regexp'] = /#{self['antenna.url']}/i
		self['antenna.title.regexp'] = /#{self['antenna.title']}/i
		self['normal-unknown.title.regexp'] = /#{self['normal-unknown.title']}/i

		# limits
		self['limit'] = Hash.new
		self['limit'][DispRef2URL::Normal] = @limit || 0
		if ( @is_long ? self['long.only_normal'] : self['short.only_normal'] ) then
			[DispRef2URL::Antenna, DispRef2URL::Search, DispRef2URL::Unknown].each do
				|c| self['limit'][c] = 0
			end
		else
			[DispRef2URL::Antenna, DispRef2URL::Search, DispRef2URL::Unknown].each do |c|
				self['limit'][c] = @limit || 0
			end
		end
		if self['unknown.hide'] then
			self['limit'][DispRef2URL::Unknown] = 0
		end
		self
	end

end

=begin
=== Tdiary::Plugin::DispRef2URL

--- DispRef2URL::new( unescaped_url, setup = nil )
      素のURLを元にしてインスタンスを生成します。((|setup|))がnilではない
      場合には、parse( ((|setup|)) ) もします。

--- DispRef2URL#restore( db )
      キャッシュから自分のURLに対応する情報を取り出します。((|db|))は
      DispRef2PStoreのインスタンスです。キャッシュされていなかった場合
      にはnilを返します。

--- DispRef2URL#parse( setup )
      DispRef2Setupのインスタンス((|setup|))にしたがって、自分を解析します。

--- DispRef2URL::Cached_options
      DispRef2Setupで設定されるオプションのうち、キャッシュに影響を与え
      るものの配列を返します。

--- DispRef2URL#store( db )
      キャッシュに自分を記録します。((|db|))はDispRef2PStoreのインスタ
      ンスです。記録に成功した場合は自分を、そうでない場合にはnilを返し
      ます。

--- DispRef2URL#==( other )
      解析結果が等しい場合に真を返します。

--- DispRef2URL#url
--- DispRef2URL#category
--- DispRef2URL#category_label
--- DispRef2URL#title
--- DispRef2URL#title_ignored
--- DispRef2URL#title_group
--- DispRef2URL#key
      それぞれ、URL、カテゴリー、カテゴリー名(ユーザーが設定しなければnil)、
      タイトル、グループ化した時に無視されたタイトル(無ければnil)、グル
      ープ化した後のタイトル、グループ化する際のキーを返します。parseあ
      るいはrestoreしないと設定されません。

=end
# handling of a URL
class DispRef2URL
	attr_reader :url, :category, :category_label, :title, :title_ignored, :title_group, :key

	# category numbers
	Normal = :normal
	Antenna = :antenna
	Search = :search
	Unknown = :unknown
	Categories = [Normal, Antenna, Search, Unknown]

	# options which affects the cache
	Cached_options = %w(
		search_engines
		cache_label
		unknown.divide
		antenna.url.regexp
		antenna.url
		antenna.title.regexp
		antenna.title
		antenna.group
		antenna.ignore_parenthesis
		normal.categorize
		normal.group
		normal.ignore_parenthesis
		cache_path
	)

	def initialize( unescaped_url, setup = nil )
		@url = unescaped_url
		@dbcopy = nil
		parse( setup ) if setup
	end

	def restore( db )
		if db.real? and (
			begin
				db[Root_DispRef2URL]
			rescue PStore::Error
				false
			end
		) and db[Root_DispRef2URL][@url] then
			@category, @category_label, @title, @title_ignored, @title_group, @key = db[Root_DispRef2URL][@url]
			self
		else
			nil
		end
	end

	def parse( setup )
		parse_as_search( setup ) || parse_as_others( setup )
		self
	end

	def store( db )
	 if db.real? and (
			begin
				db[Root_DispRef2URL] ||= Hash.new
			rescue PStore::Error
				db[Root_DispRef2URL] = Hash.new
			end
		) then
			 unless @category == DispRef2URL::Search then
				db[Root_DispRef2URL]["#{@url}"] = [ @category, @category_label, @title, @title_ignored, @title_group, @key ]
			else
				db[Root_DispRef2URL].delete( @url )
			end
			self
		else
			nil
		end
	end

	def ==(other)
		return @url == other.url &&
			@category == other.category &&
			@category_label == other.category_label &&
			@title == other.title &&
			@title_ignored == other.title_ignored &&
			@title_group == other.title_group &&
			@key == other.key
	end

	private
		def parse_as_search( setup )
			# see which search engine is used
			engine = DispRef2String::company_name( @url, setup['search_engines'] )
			return nil unless engine

			# url and query
			urlbase, query = DispRef2String::separate_query( @url )

			# get titles and keywords
			title = nil
			keyword = nil
			cached_url = nil
			values = query ? DispRef2String::parse_query( query ) : nil
			catch( :done ) do
				setup['search_engines'][engine].each do |e|
					if( e[0] =~ urlbase ) then
						title = eval( e[1] )
						if e[2].empty? then
							keyword = setup['search.unknown_keyword']
							throw :done
						end
						if String == e[2].class then
							k, c = (query ? query : @url ).instance_eval( e[2] )
							if k then
								keyword = k
							else
								keyword = setup['search.unknown_keyword']
							end
							cached_url = c ? c : nil
							throw :done
						else	# should be an Array usually
							if not values then
								keyword = setup['search.unknown_keyword']
								throw :done
							end
							e[2].each do |k|
								if( values[k] and not values[k][0].empty? ) then
									unless( e[3] and e[3] =~ values[k][0] ) then
										cached_url = nil
										keyword = values[k][0]
										throw :done
									else
										cached_url = $1
										keyword = $` + $'
										throw :done
									end
								end
							end
						end
					end
				end
			end
			return nil unless keyword

			# format
			@category = Search
			@category_label = nil
			@title = DispRef2String::normalize( setup.to_native( DispRef2String::unescape( keyword ) ) )
			@title_ignored = setup.to_native( title )
			@title_ignored << sprintf( setup['cache_label'], setup.to_native( DispRef2String::unescape( cached_url ) ) ) if cached_url
			@title_group = @title
			@key = @title_group

			self
		end

		def parse_as_others( setup )

			# try to convert with referer_table
			matched = false
			title = setup.to_native( DispRef2String::unescape( @url ) )
			setup.referer_table.each do |url, name|
				unless /\$\d/ =~ name then
					if title.gsub!( /#{url}/i, name ) then
						matched = true
						break
					end
				else
					name.untaint unless setup.secure
					if title.gsub!( /#{url}/i ) { eval name } then
						matched = true
						break
					end
				end
			end

			if setup['antenna.url.regexp'] =~ @url or setup['antenna.title.regexp'] =~ title then
			# antenna
				@category = Antenna
				@category_label = nil
				grouping = setup['antenna.group']
				ignoring = setup['antenna.ignore_parenthesis']
			elsif matched and not setup['normal-unknown.title.regexp'] =~ title then
			# normal
				@category = Normal
				if setup['normal.categorize'] and DispRef2Setup::First_bracket =~ title then
					@category_label = $1
					title = $2
				else
					@category_label = nil
				end
				grouping = setup['normal.group']
				ignoring = setup['normal.ignore_parenthesis']
			else
			# unknown
				@title = title
				@title_ignored = nil
				@title_group = title
				@key = @url
				if setup['unknown.divide'] then
					@category = Unknown
					@category_label = nil
				else
					@category = Normal
					@category_label = nil
				end
				return self
			end

			# format the title
			if not grouping then
				@title  = title
				@title_group = title
				@title_ignored = nil
				@key = url
			elsif not ignoring then
				@title = title
				@title_group = title
				@title_ignored = nil
				@key = title_group
			else
				@title = title
				@title_group = title.gsub( DispRef2Setup::Last_parenthesis, '' )
				@title_ignored = $1
				@key = title_group
			end

			self
		end

	# private
end

=begin
=== Tdiary::Plugin::DispRef2Refs
--- DispRef2Refs::new( diary, setup )
      日記((|diary|))のリンク元を、DispRef2Setupのインスタンス((|setup|))
      にしたがって解析します。

--- DispRef2Refs#special_categories
      置換文字列の最初に[]でかこったカテゴリ名ラベルを挿入することによっ
      てユーザーによって定義されたカテゴリーの配列を返します。

--- DispRef2Refs#urls( category = nil )
      リンク元のうち、カテゴリーが((|category|))に一致するものを、
      DispRef2Cache#urlsと同様のフォーマットで返します。((|category|))
      がnilの場合は全てのURLの情報を返します。

--- DispRef2Refs#to_long_html
--- DispRef2Refs#to_short_html
      リンク元のリストをHTML断片にします。

=end
class DispRef2Refs
	def initialize( diary, setup )
		@setup = setup
		@refs = Hash.new
		@has_ref = false
		return unless diary

		done_flag = Hash.new
		DispRef2URL::Categories.each do |c|
			done_flag[c] = (@setup['limit'][c] < 1)
		end

		db = @setup['no_cache'] ? DispRef2DummyPStore.new( @setup['cache_path'] ) : DispRef2PStore.new( @setup['cache_path'] )

		h = Hash.new
		db.transaction do
			diary.each_referer( diary.count_referers ) do |count, url|
				ref = DispRef2URL.new( url )
				@has_ref = true
				unless ref.restore( db ) then
					ref.parse( @setup )
					ref.store( db )
				end
				if @setup.is_long and @setup['normal.categorize'] then
					cat_key = ref.category_label || ref.category
				else
					cat_key = ref.category
				end
				next if done_flag[cat_key]
				h[cat_key] ||= Hash.new
				unless h[cat_key][ref.key] then
					h[cat_key][ref.key] = [count, ref.title_group, [[count, ref]]]
				else
					h[cat_key][ref.key][0] += count
					h[cat_key][ref.key][2] << [count, ref] if h[cat_key][ref.key].size < @setup['limit'][ref.category]
				end
				if h[cat_key].size >= @setup['limit'][ref.category] then
					done_flag[ref.category] = true
					break unless done_flag.has_value?( false )
				end
			end
		end
		db = nil

		h.each_pair do |cat_key, hash|
			@refs[cat_key] = hash.values
			@refs[cat_key].sort! { |a, b| b[0] <=> a[0] }
		end
	end

	def special_categories
		@refs.keys.reject!{ |c| DispRef2URL::Categories.include?( c ) }
	end

	# urls in the diary as a hash
	def urls( category = nil )
		h = Hash.new
		category = [ category ] unless category.class == Array
		(category ? category : @refs.keys).each do |cat|
			next unless @refs[cat]
			@refs[cat].each do |a|
				a[2].each do |b|
					h[b[1].url] = [ b[1].category, b[1].category_label, b[1].title, b[1].title_ignored, b[1].title_group, b[1].key ]
				end
			end
		end
		h
	end

	def to_short_html
		return '' if not @refs[DispRef2URL::Normal] or @refs[DispRef2URL::Normal].size < 1
		result = %Q[#{@setup['labels'][DispRef2URL::Normal]} | ]
		@refs[DispRef2URL::Normal].each do |a|
			result << %Q[<a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}" title="#{DispRef2String::escapeHTML( a[2][0][1].title )}">#{a[0]}</a> | ]
		end
		result
	end

	def to_long_html
		return '' if not @has_ref
		# we always need a caption
		result = %Q[<div class="caption">#{@setup['labels'][DispRef2URL::Normal]}</div>\n]
		result << others_to_long_html( DispRef2URL::Normal )
		if( @setup['normal.categorize'] and special_categories ) then
			special_categories.each do |cat|
				result << others_to_long_html( cat )
			end
		end
		result << others_to_long_html( DispRef2URL::Antenna )
		result << others_to_long_html( DispRef2URL::Unknown )
		result << search_to_long_html
		result
	end

	private
		def others_to_long_html( cat_key )
			return '' unless @refs[cat_key] and @refs[cat_key].size > 0
			result = ''
			unless DispRef2URL::Normal == cat_key then
				# to_long_html provides the catpion for normal links
				if @setup['labels'].has_key?( cat_key ) then
					result << %Q[<div class="caption">#{@setup['labels'][cat_key]}</div>\n]
				else
					result << %Q[<div class="caption">#{cat_key}</div>\n]
				end
			end
			result << '<ul>'
			@refs[cat_key].each do |a|
				if a[2].size == 1 then
					result << %Q[<li><a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[2][0][1].title )}</a> &times;#{a[0]}</li>\n]
				elsif not a[2][0][1].title_ignored then
					result << %Q[<li><a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[1] )}</a> &times;#{a[0]} : #{a[2][0][0]}]
					a[2][1..-1].each do |b|
						title = (b[1].title != a[1]) ? %Q[ title="#{DispRef2String::escapeHTML( b[1].title )}"] : ''
						result << %Q[, <a href="#{DispRef2String::escapeHTML( b[1].url )}"#{title}>#{b[0]}</a>]
					end
					result << "</li>\n"
				else
					result << %Q[<li>#{DispRef2String::escapeHTML( a[1] )} &times;#{a[0]} : ]
					comma = nil
					a[2][0..-1].each do |b|
						title = (b[1].title != a[1]) ? %Q[ title="#{DispRef2String::escapeHTML( b[1].title )}"] : ''
						result << comma if comma
						result << %Q[<a href="#{DispRef2String::escapeHTML( b[1].url )}"#{title}>#{b[0]}</a>]
						comma = ', '
					end
					result << "</li>\n"
				end
			end
			result << "</ul>\n"
		end

		def search_to_long_html
			return '' unless @refs[DispRef2URL::Search] and @refs[DispRef2URL::Search].size > 0
			result = %Q[<div class="caption">#{@setup['labels'][DispRef2URL::Search]}</div>\n]
			result << ( @setup['search.expand'] ? "<ul>\n" : '<ul><li>' )
			sep = nil
			@refs[DispRef2URL::Search].each do |a|
				result << sep if sep
				if @setup['search.expand'] then
					result << '<li>'
					result << DispRef2String::escapeHTML( a[1] )
				else
					result << %Q[<a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[1] )}</a>]
				end
				result << %Q[ &times;#{a[0]} ]
				if @setup['search.expand'] then
					result << ' : '
					if a[2].size < 2 then
						result << %Q[<a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[2][0][1].title_ignored )}</a>]
					else
						comma = nil
						a[2].each do |b|
							result << comma if comma
							result << %Q[<a href="#{DispRef2String::escapeHTML( b[1].url )}">#{DispRef2String::escapeHTML( b[1].title_ignored )}</a> &times;#{b[0]}]
							comma = ', ' unless comma
						end
					end
				end
				result << '</li>' if @setup['search.expand']
				sep = ( @setup['search.expand'] ? "\n" : ' / ' ) unless sep
			end
			result << ( @setup['search.expand'] ? "</ul>\n" : "</li></ul>\n" )
		end

	# private
end

=begin
=== Tdiary::Plugin::DispRef2Cache
キャッシュの管理をするクラスです。

--- DispRef2Cache.new( setup )
      リンク元のキャッシュを、DispRef2Setupのインスタンス((|setup|))にした
      がって管理します。

--- DispRef2Cache#update
      キャッシュの内容を現在の設定に従って更新します。更新されたURLの数
      を返します。

--- DispRef2Cache#size
      キャッシュファイルの大きさをバイト単位で返します。

--- DispRef2Cache#entries
      キャッシュされているURLの数を返します。

--- DispRef2Cache#urls( category = nil )
      キャッシュされているURLの情報のうち、カテゴリーが((|category|))に
      一致するものを、URLをキー、下記の配列を値としたハッシュとして返し
      ます。((|category|))がnilの場合は全てのURLの情報を返します。
      * カテゴリー
      * カテゴリーのラベル(あるいはnil)
      * 置換後の文字列
      * グループする際に無視された文字列
      * グループ全体の文字列
      * グループする際のキー

--- DispRef2Cache#unknown_urls
      キャッシュされているURLのうち、置換できなかったもののURLの配列を 
      返します。置換できなかったURLが無い場合には空の配列を返します。

=end
# cache management
class DispRef2Cache
	def initialize( setup )
		@setup = setup
	end

	# updates the cache according to the current setup
	def update
		return 0 if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		h = Hash.new
		r = 0
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction do
			begin
				db[Root_DispRef2URL].each_key do |url|
					ref = DispRef2URL::new( url )
					t = ref.restore( db )
					orig = t ? t.dup : nil
					new = ref.parse( @setup )
					if orig != new then
						r += 1
						ref.store( db )
					end
				end
			rescue PStore::Error
			end
		end
		db = nil
		r
	end

	# size of cache in bytes
	def size
		return 0 if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		FileTest.size( @setup['cache_path'] )
	end

	# number of urls in the cache
	def entries
		return 0 if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		r = 0
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction( true ) do
			begin
				r = db[Root_DispRef2URL].size
			rescue PStore::Error
				r = 0
			end
		end
		db = nil
		r
	end

	# cached urls as a hash
	def urls( category = nil )
		return {} if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		h = Hash.new
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction( true ) do
			begin
				db[Root_DispRef2URL].each_pair do |url, data|
					h[url] = data if not category or category == data[0]
				end
			rescue PStore::Error
			end
		end
		db = nil
		h
	end

	# cached unknown urls as an array
	def unknown_urls
		return [] if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		r = Array.new
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction( true ) do
			begin
				db[Root_DispRef2URL].each_pair do |url, data|
					next if DispRef2String::url_match?( url, @setup.no_referer )
					next if DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] )
					r << url if DispRef2URL::Unknown == data[0] or @setup['normal-unknown.title.regexp'] =~ data[2]
				end
			rescue PStore::Error
			end
		end
		db = nil
		r
	end

end

=begin
=== TDiary::Plugin::DispRef2SetupIF
このプラグインの設定のためのHTMLを生成し、CGIリクエストを受け取ります。

--- DispRef2SetupIF::new( cgi, setup, conf, mode )
      CGIのインスタンス((|cgi|))とDispRef2Setupのインスタンス((|setup|))
      より、設定のためのインスタンスを生成します。TDiary::Pluginより、
      @confと@modeも引数に指定してください。

--- DispRef2SetupIF#show_html
      設定の更新と必要ならキャッシュの更新をしてからHTMLを表示します。

--- DispRef2SetupIF#show_description
      このプラグインのHTML版の説明です。設定する項目も選べます。

--- DispRef2SetupIF#show_options
      このプラグインのオプションを設定するHTML断片を返します。

--- DispRef2SetupIF#show_unknown_list
      リンク元置換リストの編集のためのHTML断片を返します。

--- DispRef2SetupIF#update_options
      cgiからの入力に応じて、このプラグインのオプションを更新します。
      @setupも更新します。

--- DispRef2SetupIF#update_tables
      cgiからの入力に応じて、リンク元置換リストを更新します。
=end
# WWW Setup interface
class DispRef2SetupIF

	# setup mode
	Options = 'options'
	RefList = 'reflist'
	
	def initialize( cgi, setup, conf, mode )
		@cgi = cgi
		@setup = setup
		@conf = conf
		@conf['disp_referrer2.reflist.ignore_urls'] ||= ''
		@mode = mode
		@updated_url = nil
		@need_cache_update = false
		if @cgi.params['dr2.change_mode'] and @cgi.params['dr2.change_mode'][0] then
			case @cgi.params['dr2.new_mode'][0]
			when Options
				@current_mode = Options
			when RefList
				@current_mode = RefList
			else
				@current_mode = Options
			end
		elsif @cgi.params['dr2.current_mode'] then
			case @cgi.params['dr2.current_mode'][0]
			when Options
				@current_mode = Options
			when RefList
				@current_mode = RefList
			else
				@current_mode = Options
			end
		else
			@current_mode = Options
		end
		if not @setup.secure and not @setup['no_cache'] then
			@cache = DispRef2Cache.new( @setup )
		else
			@cache = nil
		end
	end

	# do what to do and make html
	def show_html
		# things to be done
		if @mode == 'saveconf' then
			case @current_mode
			when Options
				update_options
			when RefList
				update_tables
			end
		end

		# update cache
		if not @setup.secure then
			if not @setup['no_cache'] then
				unless @cache then
					@need_cache_update = true
					@cache = DispRef2Cache.new( @setup )
				end
				if not 'never' == @cgi.params['dr2.cache.update'][0] and ('force' == @cgi.params['dr2.cache.update'][0] or @need_cache_update) then
					@updated_url = @cache.update
				end
			else
				if @setup['no_cache'] then
					@cache = nil
				end
			end
		end

		# result
		r = show_description
		case @current_mode
		when Options
			r << show_options
		when RefList
			r << show_unknown_list
		end
		r
	end

	# show description
	def show_description
		case @conf.lang
		when 'en'
			<<-_HTML
				<h3 class="subtitle">A little bit more powerful display of referrers</h3>
			_HTML
		else
			r = <<-_HTML
				<h3 class="subtitle">本日のリンク元もうちょっとだけ強化プラグイン</h3>
				<p>$Revision: 1.31 $</p>
				<p>アンテナからのリンク、サーチエンジンの検索結果を、
					通常のリンク元の下にまとめて表示します。
					サーチエンジンの検索結果は、検索語毎にまとめられます。
					詳しくは、<a href="http://zunda.freeshell.org/d/plugin/disp_referrer2.rb">プラグインのソース</a>のドキュメントをご覧ください。
					ご意見、ご要望は、<a href="http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?disp_referrer2.rb">こちらのWiki</a>まで。</p>
			_HTML
			if DispRef2String.nora? then
				r << <<-_HTML
					<p>Noraライブラリを使っていますので、
						表示が少し速いはずです。</p>
				_HTML
			else
				r << <<-_HTML
					<p>表示速度が気になる場合は、
						<a href="http://raa.ruby-lang.org/list.rhtml?name=Nora">Nora</a>
						ライブラリをインストールしてみてください。</p>
				_HTML
			end
			if @cache then
				r << <<-_HTML if @updated_url
					<p>キャッシュのうち、#{@updated_url}個のURLが更新されました。</p>
				_HTML
				r << <<-_HTML
					<p>現在、キャッシュの大きさは#{DispRef2String::bytes( @cache.size )}バイト、
						#{DispRef2String::comma( @cache.entries )}個のURLがキャッシュされています。
						「<a href="#{@conf.update}?conf=referer">リンク元</a>」の変更の後にも
						<a href="#{@conf.update}?conf=disp_referrer2;dr2.cache.update=force;dr2.current_mode=#{@current_mode}">キャッシュの更新</a>が必要かもしれません。
					</p>
				_HTML
			end
			case @current_mode
			when Options
				r << <<-_HTML
					<p>その他のリンク元の置換リストの編集に<a href="#{@conf.update}?conf=disp_referrer2;dr2.new_mode=#{RefList};dr2.change_mode=true">移る</a>。
				_HTML
			when RefList
				r << <<-_HTML
					<p>基本的な設定に<a href="#{@conf.update}?conf=disp_referrer2;dr2.new_mode=#{Options};dr2.change_mode=true">移る</a>。
				_HTML
			end
			r << <<-_HTML
				リンク元置換リストは「<a href="#{@conf.update}?conf=referer">リンク元</a>」からも編集できます。</p>
				<input type="hidden" name="saveconf" value="ok">
				<hr>
			_HTML
			r
		end
	end

	# show options
	def show_options
		case @conf.lang
		when 'en'
			<<-_HTML
				<h4>Options</h4>
				<p>I am sorry. English page is not yet ready.</p>
			_HTML
		else
			r = <<-_HTML
				<h4>リンク元の分類と表示</h4>
				<p>
					<input name="dr2.current_mode" value="#{Options}" type="hidden">
					リンク元置換リストにないリンク元を
					<input name="dr2.unknown.divide" value="true" type="radio"#{' checked'if @setup['unknown.divide']}>#{@setup['unknown.label']}のリンク元として分ける /
					<input name="dr2.unknown.divide" value="false" type="radio"#{' checked'if not @setup['unknown.divide']}>通常のリンク元と混ぜる。
				</p>
				<p>
					#{@setup['unknown.label']}のリンク元を
					<input name="dr2.unknown.hide" value="false" type="radio"#{' checked'if not @setup['unknown.hide']}>表示する /
					<input name="dr2.unknown.hide" value="true" type="radio"#{' checked'if @setup['unknown.hide']}>隠す。
				</p>
				<p>
					リンク元置換リストの置換後の文字列の最初の[]をカテゴリー分けに
					<input name="dr2.normal.categorize" value="true" type="radio"#{' checked'if @setup['normal.categorize']}>使う /
					<input name="dr2.normal.categorize" value="false" type="radio"#{' checked'if not @setup['normal.categorize']}>使わない。
				</p>
				<p>
					一日分の表示で、通常のリンク元以外のリンク元を
					<input name="dr2.long.only_normal" value="false" type="radio"#{' checked'if not @setup['long.only_normal']}>表示する /
					<input name="dr2.long.only_normal" value="true" type="radio"#{' checked'if @setup['long.only_normal']}>隠す。
				</p>
				<p>
					最新の表示で、通常のリンク元以外のリンク元を
					<input name="dr2.short.only_normal" value="false" type="radio"#{' checked'if not @setup['short.only_normal']}>表示する /
					<input name="dr2.short.only_normal" value="true" type="radio"#{' checked'if @setup['short.only_normal']}>隠す。
					(表示する場合には、このプラグインが無い場合とまったく同じ表示になります。)
				</p>
				<h4>通常のリンク元のグループ化</h4>
				<p>
					通常のリンク元を
					<input name="dr2.normal.group" value="true" type="radio"#{' checked'if @setup['normal.group']}>置換後の文字列でまとめる /
					<input name="dr2.normal.group" value="false" type="radio"#{' checked'if not @setup['normal.group']}>URL毎に分ける。
				</p>
				<p>
					通常のリンク元を置換後の文字列でまとめる場合に、最後の()を
					<input name="dr2.normal.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['normal.ignore_parenthesis']}>無視する /
					<input name="dr2.normal.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['normal.ignore_parenthesis']}>無視しない。
				</p>
				<h4>アンテナからのリンクのグループ化</h4>
				<p>
					アンテナからのリンクを
					<input name="dr2.antenna.group" value="true" type="radio"#{' checked'if @setup['antenna.group']}>置換後の文字列でまとめる /
					<input name="dr2.antenna.group" value="false" type="radio"#{' checked'if not @setup['antenna.group']}>URL毎に分ける。
				</p>
				<p>
					アンテナからのリンクを置換後の文字列でまとめる場合に、最後の()を
					<input name="dr2.antenna.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['antenna.ignore_parenthesis']}>無視する /
					<input name="dr2.antenna.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['antenna.ignore_parenthesis']}>無視しない。
				</p>
				<h4>検索キーワードの表示</h4>
				<p>
					検索エンジン名を
					<input name="dr2.search.expand" value="true" type="radio"#{' checked'if @setup['search.expand']}>表示する /
					<input name="dr2.search.expand" value="false" type="radio"#{' checked'if not @setup['search.expand']}>表示しない。
				</p>
			_HTML
			unless @setup.secure then
			r << <<-_HTML
				<h4>キャッシュ</h4>
				<p>
					キャッシュを
					<input name="dr2.no_cache" value="false" type="radio"#{' checked'if not @setup['no_cache']}>利用する /
					<input name="dr2.no_cache" value="true" type="radio"#{' checked'if @setup['no_cache']}>利用しない。
				</p>
				<p>今回の設定変更で、キャッシュを
					<input name="dr2.cache.update" value="force" type="radio">更新する /
					<input name="dr2.cache.update" value="auto" type="radio" checked>必要なら更新する /
					<input name="dr2.cache.update" value="never" type="radio">更新しない。
				</p>
				<p>
					キャッシュの更新には多少の時間がかかる場合があります。
					OKボタンを押したらしばらくお待ちください。
					一方、キャッシュを更新しないと表示に矛盾が生じることがあります。
				</p>
			_HTML
			end # unless @setup.secure
			r
		end
	end

	# shows URL list to be added to the referer_table or no_referer
	def show_unknown_list
		if @setup.secure then
			urls = DispRef2Latest_cache.unknown_urls
		elsif @setup['no_cache'] then
			urls = DispRef2Latest.new( @cgi, 'latest.rhtml', @conf, @setup ).unknown_urls
		else
			urls = DispRef2Cache.new( @setup ).unknown_urls
		end
		case @conf.lang
		when 'en'
			<<-_HTML
				<h4>Referrer list</h4>
				<p>I am sorry. English page is not yet ready.</p>
			_HTML
		else
			r = <<-_HTML
				<h4>リンク元置換リスト</h4>
				<input name="dr2.current_mode" value="#{RefList}" type="hidden">
			_HTML
			if @cache then
				r << "<p>#{@setup['unknown.label']}のリンク元はキャッシュの中から探しています。"
			else
				r << "<p>#{@setup['unknown.label']}のリンク元は最新表示の日記から探しています。"
			end
			r << <<-_HTML
				リンク元除外リストや無視リストに一致するURLはここには表示されません。
			</p>
			<p>
				リンク元置換リストや記録除外リストには入れたくないURLは、
				無視リストに入れておくことで、
				下記のリストに現れなくなります。
				無視リストは、
				下記のリストにURLを表示するかどうかの判断にだけ使われます。
				<input name="dr2.clear_ignore_urls" value="true" type="checkbox">無視リストを空にする場合はチェックして下さい。
			</p>
			_HTML
			if urls.size > 0 then
				r << <<-_HTML
					<p>リンク元置換リストにない下記のURLを、
						リンク元置換リストに入れる場合は、
						下段の空白にタイトルを入力してください。
						また、リンク元記録除外リストに追加するには、
						チェックボックスをチェックしてください。
					</p>
					<p>
						正規表現はリンク元置換リストに追加するのに適当なものになっています。
						確認して、不具合があれば編集してください。
						リンク元置換リストにだけ追加する場合には、
						もう少しマッチの条件が緩いものでもかまいません。
					</p>
					<p>
						最後の空欄は、リンク元置換リストに追加する際のタイトルです。
						URL中に現れた「(〜)」は、
						置換文字列中で「\\1」のような「数字」で利用できます。
						また、sprintf('[tdiary:%d]', $1.to_i+1) といった、
						スクリプト片も利用できます。
					</p>
				_HTML
				if ENV['AUTH_TYPE'] and ENV['REMOTE_USER'] and @setup['configure.use_link'] then
					r << <<-_HTML
						<p>
							それぞれのURLはリンクになっていますが、これをクリックすることで、
							リンク先に、この日記の更新・設定用のURLが知られることになります。
							適切なアクセス制限が無い場合にはクリックしないようにしてください。
						</p>
					_HTML
				end
				r << <<-_HTML
					<p>
						ここにないURLは「<a href="#{@conf.update}?conf=referer">リンク元</a>」から修正してください。
					</p>
					<dl>
				_HTML
				i = 0
				urls.sort.each do |url|
					shown_url = DispRef2String::escapeHTML( @setup.to_native( DispRef2String::unescape( url ) ) )
					if ENV['AUTH_TYPE'] and ENV['REMOTE_USER'] and @setup['configure.use_link'] then
						r << "<dt><a href=\"#{url}\">#{shown_url}</a>"
					else
						r << "<dt>#{shown_url}"
					end
					r << <<-_HTML
						<dd>
							<input name="dr2.#{i}.noref" value="true" type="checkbox">除外リストに追加
							<input name="dr2.#{i}.ignore" value="true" type="checkbox">無視リストに追加<br>
							<input name="dr2.#{i}.reg" value="#{DispRef2String::escapeHTML( DispRef2String::url_regexp( url ) )}" type="text" size="70"><br>
							<input name="dr2.#{i}.title" value="" type="text" size="70">
					_HTML
					i += 1
				end
				r << <<-_HTML
					<input name="dr2.urls" type="hidden" value="#{i}">
					</dl>
				_HTML
				unless @setup.secure or @setup['no_cache'] then
					r << <<-_HTML
						<p>
							キャッシュの更新には多少の時間がかかる場合があります。
							OKボタンを押したらしばらくお待ちください。
						</p>
					_HTML
				end
			else
				r << <<-_HTML
					<p>現在、#{@setup['unknown.label']}のリンク元はありません。</p>
				_HTML
			end
			r << <<-_HTML
				<h4>アンテナのための正規表現</h4>
				<p>アンテナのURLや置換後の文字列にマッチする正規表現です。
					これらの正規表現にマッチするリンク元は「アンテナ」に分類されます。</p>
				<ul>
				<li>URL:
					<input name="dr2.antenna.url" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.url'] ) )}" type="text" size="70">
					<input name="dr2.antenna.url.default" value="true" type="checkbox">デフォルトに戻す
				<li>置換後の文字列:<input name="dr2.antenna.title" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.title'] ) )}" type="text" size="70">
					<input name="dr2.antenna.title.default" value="true" type="checkbox">デフォルトに戻す
				</ul>
				_HTML
			r
		end
	end

	# updates the options
	def update_options
		dirty = false
		# T/F options
		%w( antenna.group antenna.ignore_parenthesis antenna.search.expand
			normal.categorize normal.group normal.ignore_parenthesis
			search.expand long.only_normal short.only_normal no_cache unknown.divide
			unknown.hide
		).each do |key|
			tdiarykey = 'disp_referrer2.' + key
			case @cgi.params['dr2.' + key][0]
			when 'true'
				unless @conf[tdiarykey] == true then
					@conf[tdiarykey] = true
					@need_cache_update = true if DispRef2URL::Cached_options.include?( key )
					dirty = true
				end
			when 'false'
				unless @conf[tdiarykey] == false then
					@conf[tdiarykey] = false
					@need_cache_update = true if DispRef2URL::Cached_options.include?( key )
					dirty = true
				end
			end
		end

		# update @setup
		@setup.update! if dirty
	end

	# referer tables
	def update_tables
		dirty = false

		if @cgi.params['dr2.urls'] and @cgi.params['dr2.urls'][0].to_i > 0
			@cgi.params['dr2.urls'][0].to_i.times do |i|
				if not @cgi.params["dr2.#{i}.reg"][0].empty? and not @cgi.params["dr2.#{i}.title"][0].empty? then
					a = [
						@setup.to_native( @cgi.params["dr2.#{i}.reg"][0] ).sub( /[\r\n]+/, '' ),
						@setup.to_native( @cgi.params["dr2.#{i}.title"][0] ).sub( /[\r\n]+/, '' )
					]
					if not a[0].empty? and not a[1].empty? then
						@conf.referer_table2.unshift( a )
						@conf.referer_table.unshift( a )
							# to reflect the change in this requsest
						@need_cache_update = true
						dirty = true
					end
				end
				if 'true' == @cgi.params["dr2.#{i}.noref"][0] then
					unless @cgi.params["dr2.#{i}.reg"][0].empty? then
						reg = @setup.to_native( @cgi.params["dr2.#{i}.reg"][0] ).strip
						unless reg.empty? then
							@conf.no_referer2.unshift( reg )
							@conf.no_referer.unshift( reg	)
								# to reflect the change in this requsest
						end
					end
				end
				if 'true' == @cgi.params["dr2.#{i}.ignore"][0] then
					unless @cgi.params["dr2.#{i}.reg"][0].empty? then
						reg = @setup.to_native( @cgi.params["dr2.#{i}.reg"][0] ).strip
						unless reg.empty? then
							@conf['disp_referrer2.reflist.ignore_urls'] << reg + "\n"
							dirty = true
						end
					end
				end
			end
		end

		if @cgi.params['dr2.clear_ignore_urls'] and 'true' == @cgi.params['dr2.clear_ignore_urls'][0] then
			@conf['disp_referrer2.reflist.ignore_urls'] = ''
			dirty = true
		end

		%w( url title ).each do |cat|
			if 'true' == @cgi.params["dr2.antenna.#{cat}.default"][0]  then
				@conf["disp_referrer2.antenna.#{cat}"] = DispRef2Setup::Defaults["antenna.#{cat}"]
				dirty = true
				@need_cache_update = true
			elsif @cgi.params["dr2.antenna.#{cat}"] and @cgi.params["dr2.antenna.#{cat}"][0] and @cgi.params["dr2.antenna.#{cat}"][0] != @conf["disp_referrer2.antenna.#{cat}"] then
				newval = @cgi.params["dr2.antenna.#{cat}"][0].strip
				unless newval.empty? then
					@conf["disp_referrer2.antenna.#{cat}"] = newval
					dirty = true
					@need_cache_update = true
				end
			end
		end

		# update @setup
		@setup.update! if dirty
	end

end

=begin
=== TDiary::Plugin::DispRef2Latest
キャッシュが無い場合に、設定プラグインで不明のリンク元を得るためのクラス
です。

--- DispRef2Latest::new( cgi, skeltonfile, conf, setup )
      TDiary::TDiaryLatestの引数に加えて、DispRef2Setupのインスタンス
      ((|setup|))を引数にとります。

--- DispRef2Latest::unknown_urls
      最新の日記のリンク元のうち、置換できなかったもののURLの配列を返し
      ます。置換できなかったURLが無い場合には空の配列を返します。

=end
class DispRef2Latest < TDiary::TDiaryLatest

	def initialize( cgi, rhtml, conf, setup )
		super( cgi, rhtml, conf )
		@setup = setup
	end

	# correct unknown URLs from the newest diaries
	def unknown_urls
		r = Array.new
		self.latest( @conf.latest_limit ) do |diary|
			refs = DispRef2Refs.new( diary, @setup )
			h = refs.urls( DispRef2URL::Antenna )
			h.each_key do |url|
				next unless @setup['normal-unknown.title.regexp'] =~ h[url][2]
				next if DispRef2String::url_match?( url, @setup.no_referer )
				next if DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] )
				r << url
			end
			h = nil
			refs.urls( DispRef2URL::Unknown ).each_key do |url|
				next if DispRef2String::url_match?( url, @setup.no_referer )
				next if DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] )
				r << url
			end
		end
		r.uniq
	end

end

=begin
=== Tdiary::Plugin
--- Tdiary::Plugin#configure_disp_referrer2
      このプラグインの設定のために使われるメソッドです。add_conf_procさ
      れます。

以下は、このプラグインでオーバーライドされるtDiaryのメソッドです。
--- Tdiary::Plugin#referer_of_today_long( diary, limit = 100 )
--- Tdiary::Plugin#referer_of_today_short( diary, limit = 10 )
=end

# for configuration interface
add_conf_proc( 'disp_referrer2', 'リンク元もうちょっと強化' ) do
	setup = DispRef2Setup.new( @conf, 100, true )
	wwwif = DispRef2SetupIF.new( @cgi, setup, @conf, @mode )
	wwwif.show_html
end

# for one-day diary
def referer_of_today_long( diary, limit = 100 )
	return '' if bot?
	setup = DispRef2Setup.new( @conf, limit, true )
	DispRef2Refs.new( diary, setup ).to_long_html
end

# for newest diary
alias dispref2_original_referer_of_today_short referer_of_today_short
def referer_of_today_short( diary, limit = 10 )
	return '' if bot?
	return dispref2_original_referer_of_today_short( diary, limit ) if @options.has_key?( 'disp_referrer2.short.only_normal' ) and not @options['disp_referrer2.short.only_normal']
	setup = DispRef2Setup.new( @conf, limit, false )
	DispRef2Refs.new( diary, setup ).to_short_html
end

# we have to know the unknown urls at this moment in a secure diary
if @conf.secure and (\
	( @cgi.params['dr2.change_mode'] \
		and DispRef2SetupIF::RefList == @cgi.params['dr2.new_mode'][0] ) \
		or ( @cgi.params['dr2.current_mode'] \
		and DispRef2SetupIF::RefList == @cgi.params['dr2.current_mode'][0] ) )
then
	setup = DispRef2Setup.new( @conf, 100, true )
	DispRef2Latest_cache = DispRef2Latest.new( @cgi, 'latest.rhtml', @conf, setup )
else
	DispRef2Latest_cache = nil
end
