=begin
= ここだけ検索プラグイン((-$Id: search_control.rb,v 1.3 2003-08-28 16:54:54 zunda Exp $-))
Please see below for an English description.

== 概要
一日表示、最新表示などそれぞれについてGoogleなどの検索エンジンにインデッ
クスしてもらうかどうかを制御します。

== 使い方
このプラグインをplugin/ディレクトリに配置してください。

設定画面から「ここだけ検索」をクリックすることで、どの表示モードでどのよ
うな動作を期待するか設定することができます。デフォルトでは、一日分の表示
のみ、検索エンジンに登録されるようになっています。

実際に効果があるかどうかは、検索エンジンのロボットがメタタグを解釈して 
くれるかどうかにかかっています。

secure==trueな日記でも使えます。

= Search control plugin
== Abstract
Control whether or not to be indexed by external search engines, such as
Google, depending upon one-day view, latest view, etc.

== Usage
Put this file into the plugin/ directory. 

To set up, click `Search control' in the configuration view. You can
choose if you want crawlers from external search engines to index your
one-day view, latest view, etc. The default is to ask the crawlers to
only index one-day view.

To this plugin to take effect, we have to wish that the crawlers regards
the meta-tag.

This plugin also works in a diary with @secure = true.

== 著作権について (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.

You should be able to download the latest version from
((<URL:http://zunda.freeshell.org/d/plugin/search_control.rb>)).
=end

=begin ChangeLog
* Aug 28, 2003 zunda <zunda at freeshell.org>
- 1.3
- simpler configuration display

* Aug 26, 2003 zunda <zunda at freeshell.org>
- 1.2
- no table in configuration view, thanks to Tada-san.

* Aug 26, 2003 zunda <zunda at freeshell.org>
- no nofollow
- English translation
=end ChangeLog

# index or follow
Search_control_categories = [ 'index' ]

# [0]:index
Search_control_defaults = {
	'latest' => ['f'],
	'day' => ['t'],
	'month' => ['f'],
	'nyear' => ['f'],
	'category' => ['f'],
}

# to be used for @options and in the HTML form
Search_control_prefix = 'search_control'

# defaults
Search_control_categories.each_index do |c|
	Search_control_defaults.each_key do |view|
		cat = Search_control_categories[c]
		key = "#{Search_control_prefix}.#{view}.#{cat}"
		unless @conf[key] then
			@conf[key] = Search_control_defaults[view][c]
		end
	end
end

# configuration
add_conf_proc( Search_control_prefix,
	case @conf.lang
	when 'en'
		'Search control'
	else
		'ここだけ検索'
	end
) do

	# receive the configurations from the form
	if 'saveconf' == @mode then
		Search_control_categories.each do |cat|
			Search_control_defaults.each_key do |view|
				key = "#{Search_control_prefix}.#{view}.#{cat}"
				if 't' == @cgi.params[key][0] then
					@conf[key] = 't'
				else
					@conf[key] = 'f'
				end
			end
		end
	end

	# show the HTML
	case @conf.lang
	when 'en'
		r = <<-_HTML
		<p>Asks the crawlers from external search engines not to index
			unwanted pages. Check the viewes you want the search engines to
			index.</p>
		<ul>
		_HTML
		[
			[ 'Latest', 'latest' ], [ 'One-day', 'day' ], [ 'One-month', 'month' ],
			[ 'Same-day', 'nyear' ], [ 'Category', 'category' ]
		].each do |a|
			label = a[0]
			key = "#{Search_control_prefix}.#{a[1]}"
			r << <<-_HTML
				<li><input name="#{key}.index" value="t" type="checkbox"#{'t' == @conf["#{key}.index"] ? ' checked' : ''}>#{label}
			_HTML
		end
		r << "\t\t</ul>\n"
	else
		r = <<-_HTML
		<p>検索エンジンのロボットに、
			余分なページのインデックスを作らないようにお願いしてみます。
			インデックスを作って欲しい表示だけにチェックをしてください。</p>
		<ul>
		_HTML
		[
			[ '最新', 'latest' ], [ '一日分', 'day' ], [ '一月分', 'month' ],
			[ '長年', 'nyear' ], [ 'カテゴリー', 'category' ]
		].each do |a|
			label = a[0]
			key = "#{Search_control_prefix}.#{a[1]}"
			r << <<-_HTML
				<li><input name="#{key}.index" value="t" type="checkbox"#{'t' == @conf["#{key}.index"] ? ' checked' : ''}>#{label}
			_HTML
		end
		r << "\t\t</ul>\n"
	end
	r

end

add_header_proc do
	# modes
	if /^(latest|day|month|nyear)$/ =~ @mode then
		key = "#{Search_control_prefix}.#{@mode}"
	elsif /^category/ =~ @mode then
		key = "#{Search_control_prefix}.category"
	else
		key = nil
	end

	# output
	if key then
		%Q|\t<meta name="robots" content="#{'f' == @conf["#{key}.index"] ? 'noindex' : 'index' },follow">\n|
	else
		''
	end
end
