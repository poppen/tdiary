=begin
= A little bit more powerful display of referrers((-$Id: disp_referrer.rb,v 1.1 2004-06-15 15:19:21 tadatadashi Exp $-))
English resource

== Copyright notice
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
Disp_referrer2_name = 'Referrer classification'
Disp_referrer2_abstract = <<'_END'
<p>
	This plugin distinguishes the URLs from antennas and search engines
	and shows them separately. Search keywords from different engines are
	compound together.
</p>
_END
Disp_referrer2_with_Nora = <<'_END'
<p>
	Pages are displayed a little bit faster with the Nora library.
</p>
_END
Disp_referrer2_without_Nora = <<'_END'
<p>
	Please install the 
	<a href="http://raa.ruby-lang.org/list.rhtml?name=Nora">Nora</a>
	library if you feel the page shows too slowly.
</p>
_END
Disp_referrer2_updated_urls = <<-'_END'
<p>%d URL(s) in the cache are updated.</p>
_END
Disp_referrer2_cache_info = <<'_END'
<p>
	The cache has %2$s URL(s) in %1$s byte(s).
</p>
_END
Disp_referrer2_update_info = <<'_END'
<p>
	Please <a href="%2$s">update the cache</a>
	after editing the <a href="%1$s">today's link</a> lists.
</p>
_END
Disp_referrer2_move_to_refererlist = <<'_END'
	<a href="%s">Follow this link</a> to edit the referer lists.
_END
Disp_referrer2_move_to_config = <<'_END'
	<a href="%s">Follow this link</a> to configure the plug-in.
_END
Disp_referrer2_also_todayslink = <<'_END'
	Referer list can also be edited via &quot;<a href="%s">Today's link</a>&quot;.
_END
Disp_referrer2_antenna_label = 'Antennae'
Disp_referrer2_unknown_label = 'Others'
Disp_referrer2_search_label = 'Search engines'
Disp_referrer2_search_unknown_keyword = 'Unknown keyword'
Disp_referrer2_cache_label = '(cache from %s)'

class DispRef2SetupIF

	# show options
	def show_options
		r = <<-_HTML
			<h3>Categorization and display of referrer URLs</h3>
			<input name="dr2.current_mode" value="#{Options}" type="hidden">
			<table>
			<tr>
				<td><input name="dr2.unknown.divide" value="true" type="radio"#{' checked'if @setup['unknown.divide']}>Separate #{@setup['unknown.label']}
				<td><input name="dr2.unknown.divide" value="false" type="radio"#{' checked'if not @setup['unknown.divide']}>Treat #{@setup['unknown.label']} as normal links.
			</table>
			<table>
			<tr>
				<td><input name="dr2.unknown.hide" value="false" type="radio"#{' checked'if not @setup['unknown.hide']}>Show
				<td><input name="dr2.unknown.hide" value="true" type="radio"#{' checked'if @setup['unknown.hide']}>Hide
				separated #{@setup['unknown.label']}.
			<tr>
				<td><input name="dr2.normal.categorize" value="true" type="radio"#{' checked'if @setup['normal.categorize']}>Use
				<td><input name="dr2.normal.categorize" value="false" type="radio"#{' checked'if not @setup['normal.categorize']}>Don't use
				strings inside [ and ] to categorize normal links.
			<tr>
				<td><input name="dr2.long.only_normal" value="false" type="radio"#{' checked'if not @setup['long.only_normal']}>Show
				<td><input name="dr2.long.only_normal" value="true" type="radio"#{' checked'if @setup['long.only_normal']}>Hide
				links other than normal URLs in the daily view.
			<tr>
				<td><input name="dr2.short.only_normal" value="false" type="radio"#{' checked'if not @setup['short.only_normal']}>Show
				<td><input name="dr2.short.only_normal" value="true" type="radio"#{' checked'if @setup['short.only_normal']}>Hide
				links other than normal URLs in the latest view.
			</table>
			<h3>Grouping of normal links</h3>
			<table>
			<tr>
				<td><input name="dr2.normal.group" value="true" type="radio"#{' checked'if @setup['normal.group']}>Group with the title strings
				<td><input name="dr2.normal.group" value="false" type="radio"#{' checked'if not @setup['normal.group']}>Show each URLs
				of normal links.
			<tr>
				<td><input name="dr2.normal.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['normal.ignore_parenthesis']}>Ignore
				<td><input name="dr2.normal.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['normal.ignore_parenthesis']}>don't ignore
				the last parenthesis when grouping normal links with the titles.
			</table>
			<h3>Grouping of links from antennae</h3>
			<table>
			<tr>
				<td><input name="dr2.antenna.group" value="true" type="radio"#{' checked'if @setup['antenna.group']}>Group with the title strings
				<td><input name="dr2.antenna.group" value="false" type="radio"#{' checked'if not @setup['antenna.group']}>Show each URLs
				of links from antennae.
			<tr>
				<td><input name="dr2.antenna.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['antenna.ignore_parenthesis']}>ignore
				<td><input name="dr2.antenna.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['antenna.ignore_parenthesis']}>don't ignore
				the last parenthesis when grouping links from antennae with the titles.
			</table>
			<h3>Keywords from search engines</h3>
			<table>
			<tr>
				<td><input name="dr2.search.expand" value="true" type="radio"#{' checked'if @setup['search.expand']}>Show
				<td><input name="dr2.search.expand" value="false" type="radio"#{' checked'if not @setup['search.expand']}>Don't show
				the search engine names.
			</table>
		_HTML
		unless @setup.secure then
		r << <<-_HTML
			<h3>Cache</h3>
			<table>
			<tr>
				<td><input name="dr2.no_cache" value="false" type="radio"#{' checked'if not @setup['no_cache']}>Use
				<td><input name="dr2.no_cache" value="true" type="radio"#{' checked'if @setup['no_cache']}>Don't use
				cache.
			</table>
			<table>
			<tr>
				<td><input name="dr2.cache.update" value="force" type="radio">update
				<td><input name="dr2.cache.update" value="auto" type="radio" checked>update if needed
				<td><input name="dr2.cache.update" value="never" type="radio">don't update
				the cache at this time.
			</table>
			<p>
				Updating the cache sometimes takes time.
				Please wait after clicking the OK button.
				On the other hand, referrers might not shown correctly when
				the cache is not updated.
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
			<h3>URL Conversion</h3>
			<input name="dr2.current_mode" value="#{RefList}" type="hidden">
		_HTML
		if @cache then
			r << "<p>Picking up #{@setup['unknown.label']} from the cache."
		else
			r << "<p>Picking up #{@setup['unknown.label']} from the latest view."
		end
		r << <<-_HTML
			URLs that match the Excluding list or the Ignore list are not
			listed here.
		</p>
		<p>
			If you don't want to see the URLs that you neither put into the
			Conversion list or the Excluding list can be put in the Ignore
			list. The Ignore list only affects the list shown here.
			Please check <input name="dr2.clear_ignore_urls" value="true"
			type="checkbox">here if you want to reset the Ignore list.
		</p>
		_HTML
		if urls.size > 0 then
			r << <<-_HTML
				<p>Please fill in the titles for the URL(s) in the lower text
					box(es) to put the URL(s) into the Conversion list. Please
					check the check box(es) if you want to put the URL(s) into the
					Excluding list.
				</p>
				<p>
					Regular expressions are made up automatically. You can edit them
					if you want.
				</p>
				<p>
					In the titles, you can refer to the strings between
					parenthesis in the regular expression with something like
					&quot;\\1&quot; (backslash plus a number). You can also use
					a script fragment like &quot;sprintf('[tdiary:%d]', $1.to_i+1)&quot;.
				</p>
			_HTML
			if ENV['AUTH_TYPE'] and ENV['REMOTE_USER'] and @setup['configure.use_link'] then
				r << <<-_HTML
					<p>
						[NOTE] Be aware that by clicking the URLs below, the author
						of the www site might know the URL of this page to edit and
						configure your diary.
					</p>
				_HTML
			end
			r << <<-_HTML
				<p>
					Please edit URLs not shown here through &quot;<a
					href="#{@conf.update}?conf=referer">Today's link</a>&quot;
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
						Add this URL to
						<input name="dr2.#{i}.noref" value="true" type="checkbox">Excluding list
						<input name="dr2.#{i}.ignore" value="true" type="checkbox">Ignore list<br>
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
						Updating the cache might take some time. Please wait after
						clicking the OK button.
					</p>
				_HTML
			end
		else
			r << <<-_HTML
				<p>Currently there is no #{@setup['unknown.label']}.</p>
			_HTML
		end
		r << <<-_HTML
			<h3>Regular expressions for antennae</h3>
			<p>URLs or titles matching these expression will be categorized as
				antennae.</p>
			<ul>
			<li>URL:
				<input name="dr2.antenna.url" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.url'] ) )}" type="text" size="70">
				<input name="dr2.antenna.url.default" value="true" type="checkbox">Use default
			<li>Title:<input name="dr2.antenna.title" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.title'] ) )}" type="text" size="70">
				<input name="dr2.antenna.title.default" value="true" type="checkbox">Use default
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
		[%r{^http://.*?\bgoogle\.([^/]+)/(search|custom|ie)}i, '"Google in .#{$1}"', ['as_q', 'q', 'as_epq'], DispReferrer2_Google_cache],
		[%r{^http://.*?\bgoogle\.([^/]+)/.*url}i, '"Google URL search in .#{$1}"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{^http://.*?\bgoogle/search}i, '"Google?"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{^http://eval.google\.([^/]+)}i, '"Google Accounts in .#{$1}"', [], nil],
		[%r{^http://.*?\bgoogle\.([^/]+)}i, '"Google in .#{$1}"', [], nil],
	],
	'yahoo' => [
		[%r{^http://.*?\.rd\.yahoo\.([^/]+)}i, '"Yahoo! redirector.#{$1}"', 'split(/\*/)[1]', nil],
		[%r{^http://.*?\.yahoo\.([^/]+)}i, '"Yahoo! search in .#{$1}"', ['p', 'va', 'vp'], DispReferrer2_Google_cache],
	],
	'netscape' => [[%r{^http://.*?\.netscape\.([^/]+)}i, '"Netscape search in .#{$1}"', ['search', 'query'], DispReferrer2_Google_cache]],
	'msn' => [[%r{^http://.*?\.MSN\.([^/]+)}i, '"MSN search in .#{$1}"', ['q', 'MT'], nil ]],
	'metacrawler' => [[%r{^http://.*?.metacrawler.com}i, '"MetaCrawler"', ['q'], nil ]],
	'metabot' => [[%r{^http://.*?\.metabot\.ru}i, '"MetaBot.ru"', ['st'], nil ]],
	'altavista' => [[%r{^http://.*?\.altavista\.([^/]+)}i, '"Altavista in .#{$1}"', ['q'], nil ]],
	'infoseek' => [[%r{^http://(www\.)?infoseek\.co\.jp}i, '"Infoseek"', ['qt'], nil ]],
	'odn' => [[%r{^http://.*?\.odn\.ne\.jp}i, '"ODN検索"', ['QueryString', 'key'], nil ]],
	'lycos' => [[%r{^http://.*?\.lycos\.([^/]+)}i, '"Lycos in .#{$1}"', ['query', 'q', 'qt'], nil ]],
	'fresheye' => [[%r{^http://.*?\.fresheye}i, '"Fresheye"', ['kw'], nil ]],
	'goo' => [
		[%r{^http://.*?\.goo\.ne\.jp}i, '"goo"', ['MT'], nil ],
		[%r{^http://.*?\.goo\.ne\.jp}i, '"goo"', [], nil ],
	],
	'nifty' => [
		[%r{^http://search\.nifty\.com}i, '"@nifty/@search"', ['q', 'Text'], DispReferrer2_Google_cache],
		[%r{^http://srchnavi\.nifty\.com}i, '"@nifty redirector"', ['title'], nil ],
	],
	'eniro' => [[%r{^http://.*?\.eniro\.se}i, '"Eniro"', ['q'], DispReferrer2_Google_cache]],
	'excite' => [[%r{^http://.*?\.excite\.([^/]+)}i, '"Excite in .#{$1}"', ['search', 's', 'query', 'qkw'], nil ]],
	'biglobe' => [
		[%r{^http://.*?search\.biglobe\.ne\.jp}i, '"BIGLOBE search"', ['q'], nil ],
		[%r{^http://.*?search\.biglobe\.ne\.jp}i, '"BIGLOBE search"', [], nil ],
	],
	'dion' => [[%r{^http://dir\.dion\.ne\.jp}i, '"Dion"', ['QueryString', 'key'], nil ]],
	'naver' => [[%r{^http://.*?\.naver\.co\.jp}i, '"NAVER Japan"', ['query'], nil ]],
	'webcrawler' => [[%r{^http://.*?\.webcrawler\.com}i, '"WebCrawler"', ['qkw'], nil ]],
	'euroseek' => [[%r{^http://.*?\.euroseek\.com}i, '"Euroseek.com"', ['string'], nil ]],
	'aol' => [[%r{^http://.*?\.aol\.}i, '"AOL search"', ['query'], nil ]],
	'alltheweb' => [
		[%r{^http://.*?\.alltheweb\.com}i, '"AlltheWeb.com"', ['q'], nil ],
		[%r{^http://.*?\.alltheweb\.com}i, '"AlltheWeb.com"', [], nil ],
	],
	'kobe-u' => [
		[%r{^http://bach\.scitec\.kobe-u\.ac\.jp/cgi-bin/metcha.cgi}i, '"Metcha search engine"', ['q'], nil ],
		[%r{^http://bach\.istc\.kobe-u\.ac\.jp/cgi-bin/metcha.cgi}i, '"Metcha search engine"', ['q'], nil ],
	],
	'tocc' => [[%r{^http://www\.tocc\.co\.jp/search/}i, '"TOCC/Search"', ['QRY'], nil ]],
	'yappo' => [[%r{^http://i\.yappo\.jp/}i, '"iYappo"', [], nil ]],
	'suomi24' => [[%r{^http://.*?\.suomi24\.([^/]+)/.*query}i, '"Suomi24"', ['q'], DispReferrer2_Google_cache]],
	'earthlink' => [[%r{^http://search\.earthlink\.net/search}i, '"EarthLink Search"', ['as_q', 'q', 'query'], DispReferrer2_Google_cache]],
	'infobee' => [[%r{^http://infobee\.ne\.jp/}i, '"Infobee"', ['MT'], nil ]],
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
	'odin' => [[%r{^http://odin\.ingrid\.org}i, '"ODiN"', ['key'], nil]],
	'kensaku' => [[%r{^http://www\.kensaku\.}i, '"kensaku.jp"', ['key'], nil]],
	'hotbot' => [[%r{^http://www\.hotbot\.}i, '"HotBot Web Search"', ['MT'], nil ]],
	'searchalot' => [[%r{^http://www\.searchalot\.}i, '"Searchalot"', ['q'], nil ]],
	'cometsystems' => [[%r{^http://search\.cometsystems\.com}i, '"Comet Web Search"', ['qry'], nil ]],
	'bulkfeeds' => [
	    [%r{^http://bulkfeeds\.net/app/search2}i, '"Bulkfeeds: RSS Directory & Search"', ['q'], nil ],
	    [%r{^http://bulkfeeds\.net/app/similar}i, '"Bulkfeeds Similarity Search"', ['url'], nil ],
	],
	'answerbus' => [[%r{^http://www\.answerbus\.com}i, '"AnswerBus"', [], nil ]],
	'dogplile' => [[%r{^http://www.\dogpile\.com/info\.dogpl/search/web/}i, '"AnswerBus"', [], nil ]],
	'www' => [[%r{^http://www\.google/search}i, '"Google?"', ['as_q', 'q'], DispReferrer2_Google_cache]],	# TLD missing
	'planet' => [[%r{^http://www\.planet\.nl/planet/}i, '"Planet-Zoekpagina"', ['googleq', 'keyword'], DispReferrer2_Google_cache]], # googleq parameter has a strange prefix
	'216' => [[%r{^http://(\d+\.){3}\d+/search}i, '"Google?"', ['as_q', 'q'], DispReferrer2_Google_cache]],	# cache servers of google?
}
