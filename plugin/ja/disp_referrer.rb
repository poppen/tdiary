=begin
= 本日のリンク元もうちょっとだけ強化プラグイン((-$Id: disp_referrer.rb,v 1.3 2003-10-20 13:31:05 zunda Exp $-))
日本語リソース

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
See ../ChangeLog for changes after this.

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

# Hash table of search engines
# key: company name
# value: array of:
# [0]:url regexp [1]:title [2]:keys for search keyword [3]:cache regexp
DispReferrer2_Google_cache = /cache:[^:]+:([^+]+)+/
DispReferrer2_Engines = {
	'google' => [
		[%r{^http://.*?\bgoogle\.([^/]+)/(search|custom|ie)}i, '".#{$1}のGoogle検索"', ['as_q', 'q', 'as_epq'], DispReferrer2_Google_cache],
		[%r{^http://.*?\bgoogle\.([^/]+)/.*url}i, '".#{$1}のGoogleのURL検索?"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{^http://.*?\bgoogle/search}i, '"たぶんGoogle検索"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{^http://eval.google\.([^/]+)}i, '".#{$1}のGoogle Accounts"', [], nil],
		[%r{^http://.*?\bgoogle\.([^/]+)}i, '".#{$1}のGoogle検索"', [], nil],
	],
	'yahoo' => [
		[%r{^http://.*?\.rd\.yahoo\.([^/]+)}i, '".#{$1}のYahooのリダイレクタ"', 'split(/\*/)[1]', nil],
		[%r{^http://.*?\.yahoo\.([^/]+)}i, '".#{$1}のYahoo!検索"', ['p', 'va', 'vp'], DispReferrer2_Google_cache],
	],
	'netscape' => [[%r{^http://.*?\.netscape\.([^/]+)}i, '".#{$1}のNetscape検索"', ['search', 'query'], DispReferrer2_Google_cache]],
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
		[%r{^http://search\.nifty\.com}i, '"@nifty/@search"', ['q', 'Text'], DispReferrer2_Google_cache],
		[%r{^http://srchnavi\.nifty\.com}i, '"@niftyのリダイレクタ"', ['title'], nil ],
	],
	'eniro' => [[%r{^http://.*?\.eniro\.se}i, '"Eniro"', ['q'], DispReferrer2_Google_cache]],
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
	'suomi24' => [[%r{^http://.*?\.suomi24\.([^/]+)/.*query}i, '"Suomi24"', ['q'], DispReferrer2_Google_cache]],
	'earthlink' => [[%r{^http://search\.earthlink\.net/search}i, '"EarthLink Search"', ['as_q', 'q', 'query'], DispReferrer2_Google_cache]],
	'infobee' => [[%r{^http://infobee\.ne\.jp/}i, '"新鮮情報検索"', ['MT'], nil ]],
	't-online' => [[%r{^http://brisbane\.t-online\.de/}i, '"T-Online"', ['q'], DispReferrer2_Google_cache]],
	'walla' => [[%r{^http://find\.walla\.co\.il/}i, '"Walla! Channels"', ['q'], nil ]],
	'mysearch' => [[%r{^http://.*?\.mysearch\.com/}i, '"My Search"', ['searchfor'], nil ]],
	'jword' => [[%r{^http://search\.jword.jp/}i, '"JWord"', ['name'], nil ]],
	'nytimes' => [[%r{^http://query\.nytimes\.com/search}i, '"New York Times: Search"', ['as_q', 'q', 'query'], DispReferrer2_Google_cache]],
	'aaacafe' => [[%r{^http://search\.aaacafe\.ne\.jp/search}i, '"AAA!CAFE"', ['key'], nil]],
	'virgilio' => [[%r{^http://search\.virgilio\.it/search}i, '"VIRGILIO Ricerca"', ['qs'], nil]],
	'ceek' => [[%r{^http://www\.ceek\.jp}i, '"ceek.jp"', ['q'], nil]],
	'cnn' => [[%r{^http://websearch\.cnn\.com}i, '"CNN.com"', ['query', 'as_q', 'q', 'as_epq'], DispReferrer2_Google_cache]],
	'webferret' => [[%r{^http://webferret\.search\.com}i, '"WebFerret"', 'split(/,/)[1]', nil]],
	'eniro' => [[%r{^http://www\.eniro\.se}i, '"Eniro"', ['query', 'as_q', 'q'], DispReferrer2_Google_cache]],
	'passagen' => [[%r{^http://search\.evreka\.passagen\.se}i, '"Eniro"', ['q', 'as_q', 'query'], DispReferrer2_Google_cache]],
	'redbox' => [[%r{^http://www\.redbox\.cz}i, '"RedBox"', ['srch'], nil]],
	'odin' => [[%r{^http://odin\.ingrid\.org}i, '"ODiN検索"', ['key'], nil]],
	'kensaku' => [[%r{^http://www\.kensaku\.}i, '"kensaku.jp検索"', ['key'], nil]],
	'hotbot' => [[%r{^http://www\.hotbot\.}i, '"HotBot Web Search"', ['MT'], nil ]],
	'searchalot' => [[%r{^http://www\.searchalot\.}i, '"Searchalot"', ['q'], nil ]],
	'cometsystems' => [[%r{^http://search\.cometsystems\.com}i, '"Comet Web Search"', ['qry'], nil ]],
	'www' => [[%r{^http://www\.google/search}i, '"Google検索?"', ['as_q', 'q'], DispReferrer2_Google_cache]],	# TLD missing
	'planet' => [[%r{^http://www\.planet\.nl/planet/}i, '"Planet-Zoekpagina"', ['googleq', 'keyword'], DispReferrer2_Google_cache]], # googleq parameter has a strange prefix
	'216' => [[%r{^http://(\d+\.){3}\d+/search}i, '"Google検索?"', ['as_q', 'q'], DispReferrer2_Google_cache]],	# cache servers of google?
}
