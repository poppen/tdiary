=begin
= 本日のリンク元もうちょっとだけ強化プラグイン((-$Id: disp_referrer.rb,v 1.4 2003-10-21 17:45:15 zunda Exp $-))
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

# Message strings
Disp_referrer2_name = 'リンク元もうちょっと強化'
Disp_referrer2_abstract = <<'_END'
	アンテナからのリンク、サーチエンジンの検索結果を、
	通常のリンク元の下にまとめて表示します。
	サーチエンジンの検索結果は、検索語毎にまとめられます。
_END
Disp_referrer2_with_Nora = <<'_END'
<p>
	Noraライブラリを使っていますので、表示が少し速いはずです。
</p>
_END
Disp_referrer2_without_Nora = <<'_END'
<p>
	表示速度が気になる場合は、
	<a href="http://raa.ruby-lang.org/list.rhtml?name=Nora">Nora</a>
	ライブラリをインストールしてみてください。
</p>
_END
Disp_referrer2_updated_urls = <<'_END'
<p>キャッシュのうち、%d個のURLが更新されました。</p>
_END
Disp_referrer2_cache_info = <<'_END'
<p>
	現在、キャッシュの大きさは%1$sバイト、
	%2$s個のURLがキャッシュされています。
</p>
_END
Disp_referrer2_update_info = <<'_END'
<p>
	「<a href="#{@conf.update}?conf=referer">リンク元</a>」の変更の後にも
	<a href="#{@conf.update}?conf=disp_referrer2;dr2.cache.update=force;dr2.current_mode=#{@current_mode}">キャッシュの更新</a>
	が必要かもしれません。
</p>
_END
Disp_referrer2_move_to_refererlist = <<'_END'
	その他のリンク元の置換リストの編集に<a href="#{@conf.update}?conf=disp_referrer2;dr2.new_mode=#{RefList};dr2.change_mode=true">移る</a>。
_END
Disp_referrer2_move_to_config = <<'_END'
	基本的な設定に<a href="#{@conf.update}?conf=disp_referrer2;dr2.new_mode=#{Options};dr2.change_mode=true">移る</a>。
_END
Disp_referrer2_also_todayslink = <<'_END'
	リンク元置換リストは「<a href="%s?conf=referer">リンク元</a>」からも編集できます。
_END
Disp_referrer2_antenna_label = 'アンテナ'
Disp_referrer2_unknown_label = 'その他のリンク元'
Disp_referrer2_search_label = '検索'
Disp_referrer2_search_unknown_keyword = 'キーワード不明'
Disp_referrer2_cache_label = '(%sのキャッシュ)'

class DispRef2SetupIF

	# show options
	def show_options
		r = <<-_HTML
			<h4>リンク元の分類と表示</h4>
			<p>
				<input name="dr2.current_mode" value="#{Options}" type="hidden">
				リンク元置換リストにないリンク元を
				<input name="dr2.unknown.divide" value="true" type="radio"#{' checked'if @setup['unknown.divide']}>#{@setup['unknown.label']}として分ける /
				<input name="dr2.unknown.divide" value="false" type="radio"#{' checked'if not @setup['unknown.divide']}>通常のリンク元と混ぜる。
			</p>
			<p>
				#{@setup['unknown.label']}を
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

	# shows URL list to be added to the referer_table or no_referer
	def show_unknown_list
		if @setup.secure then
			urls = DispRef2Latest_cache.unknown_urls
		elsif @setup['no_cache'] then
			urls = DispRef2Latest.new( @cgi, 'latest.rhtml', @conf, @setup ).unknown_urls
		else
			urls = DispRef2Cache.new( @setup ).unknown_urls
		end
		r = <<-_HTML
			<h4>リンク元置換リスト</h4>
			<input name="dr2.current_mode" value="#{RefList}" type="hidden">
		_HTML
		if @cache then
			r << "<p>#{@setup['unknown.label']}はキャッシュの中から探しています。"
		else
			r << "<p>#{@setup['unknown.label']}は最新表示の日記から探しています。"
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
				<p>現在、#{@setup['unknown.label']}はありません。</p>
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
