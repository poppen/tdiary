=begin
= ここだけ検索プラグイン((-$Id: search_control.rb,v 1.2 2003-10-13 15:15:43 zunda Exp $-))
日本語リソース

== 概要
一日表示、最新表示などそれぞれについてGoogleなどの検索エンジンにインデッ
クスしてもらうかどうかを制御します。

== 使い方
このプラグインをplugin/ディレクトリに配置するか、プラグイン選択プラグイ
ンを使ってこのプラグインを有効にしてください。

設定画面から「ここだけ検索」をクリックすることで、どの表示モードでどのよ
うな動作を期待するか設定することができます。デフォルトでは、一日分の表示
のみ、検索エンジンに登録されるようになっています。

実際に効果があるかどうかは、検索エンジンのロボットがメタタグを解釈して 
くれるかどうかにかかっています。

secure==trueな日記でも使えます。

== 著作権について (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

=begin ChangeLog
See ../ChangeLog for changes after this.

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

# configuration
@search_control_plugin_name = 'ここだけ検索'
@search_control_description_html = <<-'_HTML'
	<p>メタタグを使って、検索エンジンのロボットに、
		余分なページのインデックスを作らないようにお願いしてみます。
		インデックスを作って欲しい表示だけにチェックをしてください。</p>
	_HTML
@search_control_categorirs = [
	[ '最新', 'latest' ], [ '一日分', 'day' ], [ '一月分', 'month' ],
	[ '長年', 'nyear' ], [ 'カテゴリー', 'category' ]
]
