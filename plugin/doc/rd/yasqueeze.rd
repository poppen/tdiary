=begin
= yasqueeze.rb　- Yet Another squeeze.rb

== 機能
tDiary-1.3.x以降で系標準でついてくるsqueeze.rbの拡張版です。
tDiaryのデータベースから日別にHTMLファイルを生成し、任意のディレクトリに保存します。
検索エンジン(主にNamazu)での使用を想定しています。

 * 日記本文からツッコミまでを再現
 * 非表示の日記を対象にするかどうかを選択できる
 * 年別にディレクトリを作成（1ディレクトリ最大365ファイル）、または全てのファイルをを一つのディレクトリに作成(tDiary互換モード)
 * CGIとしてもコマンドとしてもtDiaryプラグインとしても動作する

== 使い方
yasqueeze.rbは3つの使い方ができます。

=== プラグインとして使用(1日の日記をHTML化する)
tDiaryは標準でも更新時にHTMLファイルを任意のディレクトリに格納することができますが、ツッコミなどが保存されない、HTML形式ではない、など不完全です。
用途によってはそれで充分ですが、yasqueeze.rbプラグインを使えば完全なHTMLを生成できます。また、ディレクトリを年別に保存しますので、若干ファイルの視認性があがります（ほんとか？）。ただし、tDiaryと同様に1つのディレクトリに全てのファイルを置くことも可能です。

* tdiary.confを変更します。 まず、@text_outputはfalseにします。

 @text_output = false
 @text_output_path = ''

* 次にtdiary.confに以下のオプションを追加します。

 # 出力先ディレクトリ
 @options['yasqueeze.output_path'] = '/home/hoge/tdiary/html/'
 # 非表示の日記も対象とする場合はtrue。falseにした場合は非表示の日記は出力せず、かつ、すでに出力済みのファイルが存在した場合は削除します。
 # 検索エンジンで使用することを想定した場合、ここをtrueにしてしまうと隠しているつもりの日記も検索対象になってしまうので注意が必要です。
 @options['yasqueeze.all_data'] = false
 # squeeze.rb、tDiary標準と同じ出力先のディレクトリ構成にする場合はtrue
 @options['yasqueeze.compat_path'] = false
 
* 出力先のディレクトリを作成します。このディレクトリはWWWサーバが書込権限を持っている必要がありますので必要に応じてchmodしてください。
  上記指定の場合は /home/hoge/tdiary/htmlとなります。

* pluginディレクトリにyasqueeze.rbを置きます。

これだけで、日記を登録・更新・ツッコミを登録するたびにHTMLファイルが生成されるようになります。

=== 全ての日記を日別にHTML化する
1からtDiaryを使う人はプラグインとしてyasqueeze.rbを使うだけでこちらは特に必要ないのですが、すでにtDiaryを運用している場合、いっぺんに過去の日記をHTML化したい場合があります。
そのような場合は以下の2つの方法でHTMLを生成できます。

==== CGIとして使用
* 次にtdiary.confにPluginとして使う場合と同じオプションを追加します。

 @options['yasqueeze.output_path'] = '/home/hoge/tdiary/html/'
 @options['yasqueeze.all_data'] = false
 @options['yasqueeze.compat_path'] = false
 
  また、必要に応じて、1行目の#!/usr/bin/env ruby　行を変更します。 

* 出力先のディレクトリを作成します。
  このディレクトリはWWWサーバが書込権限を持っている必要がありますので必要に応じてchmodしてください。
  上記指定の場合は /home/hoge/tdiary/htmlとなります。

* tDiaryがあるサーバと同じサーバのtdiaryディレクトリ直下(index.rbやupdate.rb、tdiary.confがあるディレクトリ)にyasqueeze.rbを置き、index.rb,update.rbと同じアクセス権限にします。

* WWWブラウザからhttp://hogehoge/tdiary/yasqueeze.rbにアクセスします。

==== コマンドとして使用
tDiaryがあるサーバと同じサーバで実行する必要があります。tdiary.confで指定した@data_pathへの書込権限が必要です。
* 出力先のディレクトリを作成します。
  このディレクトリはカレントユーザが書込権限を持っている必要がありますので必要に応じてchmodしてください。
* yasqueeze.rbを実行します。

  $ruby squeeze.rb [-p <tDiary path>] [-c <tdiary.conf path>] [-a] [-s] <dest path>

:-p <tDiary path>
  tDiaryのインストールパス。未指定時はカレントディレクトリ(例: -p /homge/hoge/tdiary)。
:-c <tdiary.conf path>
  tdiary.confが存在するパス。未指定時はカレントディレクトリ(例: -c /home/hoge/public_html/diary)。
:-a
  非表示の日記も対象とする。未指定時は非表示の日記は出力せず、かつ、すでに出力済みのファイルが存在した場合は削除する。
:-s
  squeeze.rbモード。squeeze.rb、tDiary標準と同じ出力先のディレクトリ構成にする。
:<dest path>
  HTMLファイルの生成先ディレクトリ。
  
* 生成したファイルとディレクトリを、そのままプラグイン等で使用する場合は、WWWサーバが書込権限を持っている必要がありますので必要に応じてchmodしてください。

=== Namazuで使用する
yasqueeze.rbは主にNamazu等の検索エンジンで使用することを目的としています。ここでは、典型的なNamazuの設定方法を示します。

* /home/hoge/namazu - Namazuのインデックスファイルのあるディレクトリ
* /home/hoge/html/  - yasqueeze.rbの出力先
* /home/hoge/public_html/tdiary/ - tdiaryのあるディレクトリ
* /home/hoge/public_html/namazu/ - namazu.cgi, .namazurcのあるディレクトリ
* http://www.hoge.com/hoge/tdiary/ - tdiaryのURL(/home/hoge/public_html/tdiary/にマッピング)
* http://www.hoge.com/hoge/namazu/ - namazu.cgiのURL(/home/hoge/public_html/namazu/にマッピング)

に指定されているとします。

==== オリジナルモード(@options['yasqueeze.compat_path'] = false)の場合
以下のようにファイルが生成されます。

 /home/hoge/html/2000/0101( ... 1231)
 /home/hoge/html/2001/0101( ... 1231)
 /home/hoge/html/2002/0101( ... 1231)

.namazurcの内容を以下のようにします。

 Index /home/hoge/namazu/
 Replace /home/hoge/html/(\d\d\d\d)/ http://www.hoge.com/hoge/tdiary/?date=\1
 Lang ja

==== tDiary互換モード(@options['yasqueeze.compat_path'] = true)の場合
以下のようにファイルが生成されます。

 /home/hoge/html/20000101( ... 20001231)
 /home/hoge/html/20010101( ... 20011231)
 /home/hoge/html/20020101( ... 20021231)

.namazurcの内容を以下のようにします。

 Index /home/hoge/namazu/
 Replace /home/hoge/html/ http://www.hoge.com/hoge/tdiary/?date=
 Lang ja

=== Namazuのインデックスを生成
ファイルが生成できれば、あとはそれを元にNamazuのインデックスファイルを生成します。

 $mknmz /home/hoge/html --output-dir=/home/hoge/namazu

=== 動作確認
これでhttp://www.hoge.com/namazu/namazu.cgiでNamazuから検索できると思います。できなかったらご一報を(^^;)。

=== tDiaryから検索できるようにする
tDiaryに検索用のフォームを表示させることもできます。tDiaryの設定画面から、お気に入りの場所に以下のテキストを挿入します。

 <div class="search">
  <form class="search" method="get" action="/namazu/namazu.cgi">
  <input class="search" type="text" name="query" size=20 value="">
  <input class="search" type="submit" value="Search">
  </form>
 </div>

上記例では、classを分けてあるので、CSSを使えばデザインをいろいろと変更できます。

((<search_form.rb|URL:search_form.html>))を使うと、以下のように書くことができます。

 <div class="search">
 <%=namazu_form "/namazu/namazu.cgi"%>
 </div>

こっちの方が簡単ですね。

== ライセンスについて
Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>

本ソフトウェアはGNU General Public License Version 2(GNU一般公有使用許諾書バージョン2)に基づいてリリースされるフリーソフトウェアです。
また、本プログラムは無保証です。本プログラムの利用により何らかのトラブルが生じても、当方は一切責任を負いません。

なお、このスクリプトはsqueeze.rbの拡張版です。squeeze.rbのライセンスは以下の通りです。

Copyright (C) 2001,2002, All right reserved by TADA Tadashi <sho@spc.gr.jp>
You can redistribute it and/or modify it under GPL2.

== メンテナ
本ソフトウェアについてのご意見・バグレポートは武藤まで。
MUTOH Masao <mutoh@highway.ne.jp>

== ChangeLog
:2002-03-31 MUTOH Masao  <mutoh@highway.ne.jp>
    * TAB → スペース
    * ドキュメントチェックイン

:2002-03-29 MUTOH Masao  <mutoh@highway.ne.jp>
    * 出力ファイルを日付の昇順でソートするようにした
    * squeeze.rbと同様のコマンドオプションをサポートした
      （ただし --deleteオプションはなく代わりに--allオプションを用意）
    * コマンドラインオプションを追加したことで不要になった--nohtmlオプションをなくした
    * ドキュメント再見直し
    * tdiary.confの@options対応
    * add_update_proc do 〜　end 対応(このため、tDiary-1.3.x系では動かなくなりました)
    * version 1.2.0

:2002-03-21 MUTOH Masao  <mutoh@highway.ne.jp>
    * 非表示の日記を出力対象に含めるかどうかを設定できるようにした
    * ファイルの保存ディレクトリの構成を、tDiary標準のものとversion 1.0.0
      のものを設定できるようにした
    * ドキュメントをソースから追い出した
    * version 1.1.0

:2002-03-19 MUTOH Masao <mutoh@highway.ne.jp>
    * version 1.0.0

=end
