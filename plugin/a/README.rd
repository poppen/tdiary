=begin
= a.rb - アンカー自動生成プラグイン

== 機能
アンカーを自動生成してくれます。
単純に、URLと名称を指定すればアンカーになりますし、辞書ファイルに登録しておけば短いキーワードからアンカーを表示してくれます。

* 指定方法が簡単である
* 今後、登録しておいたURLが変更された場合でも辞書ファイルを変更するだけで追随できる
  → 過去にさかのぼって日記自体を修正し直す必要がありません
* myとほぼ同機能を実現(title指定はできません)
* tlink拡張でtlinkとほぼ同機能を実現(title指定はできません)
  tDiaryプラグイン集に標準添付のtlinkの機能である「アンカーのtitle属性値にリンク先の情報を指定させる」ことができます。
* 辞書ファイルをWWWの管理画面から登録できる
  辞書ファイルはテキストファイルなのでそのまま編集することもできますが、WWWの管理画面を利用すればさらに簡単に管理できます。

== 必要環境
* tDiary-1.5.3 or later
* ruby-1.6.x or later

== インストール
* a.rb - プラグイン本体(pluginディレクトリに置いてください)
* a_conf.rb - 管理用CGI(辞書ファイル編集)(本体)(オプション、tDiary直下(tdiary.rbと同じディレクトリ)に置いてください)
* a_conf.rhtml - 管理用CGI(辞書ファイル編集)(オプション、skelディレクトリに置いてください)

管理WWW画面を使う場合は、a_conf.rb, a_conf.rhtmlの２つが必要です。

== 使う場所
本文、ヘッダ、もしくはフッタ

== 利用方法
本プラグインは a()というメソッドを提供しますが、大きく2つの使い方があります。

=== 引数から単純にアンカーを生成する方法
--- a "url"
--- a "name|url"
     * name - そのリンク先の名称(省略可能。省略した場合はurlが名称として表示される)
     * url - URL
 
 例：
 <%= a "http://www.hoge.com/" %>
 <%= a "hoge|http://www.hoge.com/" %>

これらは以下のような結果になります。
 結果：
 <a href="http://www.hoge.com/">hoge</a>
 <a href="http://www.hoge.com/">http://www.hoge.com/</a>

=== my形式
tDiary標準のmyプラグイン(あるいはmy-exプラグイン)と同じ機能を提供します。
実際にmyプラグインを呼び出しますのでそちらは別途インストールしておく必要があります(デフォルトでインストールされています)。
--- a "name|YYYYMMDD#..."
     * name - そのリンク先の名称(省略できません)
     * YYYYMMDD#... - 「YYYYMMDD#pXX」(YYYY年MM月DD日のXX番目のセクション)や「YYYYMMDD#cXX」(YYYY年MM月DD日のXX番目のツッコミ)のような形>式で指定します。

 例：
 <%= a "以前言ってたこと|20030101#p01" %>


=== 辞書ファイルからURLを検索してアンカーを生成する方法
あらかじめ、辞書ファイルを用意しておき、keyに該当するデータを元にアンカーを生成します。keyに該当するデータがない場合は1つ目の出力結果と同様になります。

--- a "name|key:option"
     * name - そのリンク先の名称。辞書ファイルに記述した名称より優先されます。(省略可能。省略した場合は辞書ファイルに記述した名称が表示され、さらに辞書ファイルに名称が無い場合はnameが名称として表示される)
     * key - キー(辞書ファイルのキーワード)。辞書ファイルのURLに展開されます。
     * option - URLに追加する文字列(省略可能)。日本語はURLエンコードされます(defaultはeuc、辞書ファイルに指定することでsjis/jisも指定可能)。

 例：
 <%= a "tDiary.Net" %>
 <%= a "h" %>
 <%= a "bibo:20020329" %>
 <%= a "こちら|bibo:20020329" %>
 <%= a "プラグインはこちら|users:プラグイン" %>

例えば、後述するa.datをそのまま利用したとすると以下のような結果になります。

 結果：
 <a href="http://www.tdiary.net/">tDiary.Net</a>
 <a href="http://ponx.s5.xrea.com/">My Home Page</a>
 <a href="http://ponx.s5.xrea.com/bibo/?date=20020329">Linuxビボ〜ろく</a>
 <a href="http://ponx.s5.xrea.com/bibo/?date=20020329">こちら</a>
 <a href="http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?%A5%D7%A5%E9%A5%B0%A5%A4%A5%F3">プラグインはこちら</a>

=== Another way
上述の方法の他に以下のような指定もできます(1.3.0まではこちらしかできませんでした)。
nameの順序が逆転しています（一番最後になっている）。もし、上述の方法でうまくいかない場合(例えば、nameやoptionに|や:が区切り文字が出てきてしまう場合)に使うと良いでしょう。

 <%= a "http://www.hoge.com/" %>
 <%= a "http://www.hoge.com/", "hoge" %>
 <%= a "20020202#p01", "以前言ってたこと" %>
 <%= a "tDiary.Net" %>
 <%= a "h" %>
 <%= a "bibo", "20020329" %>
 <%= a "bibo", "20020329", "こちら" %>
 <%= a "users", "プラグイン", "プラグインはこちら" %>

== 表用例
((:<a href="http://www.tdiary.net/">tDiary.Net</a><a href="http://ponx.s5.xrea.com/">My Home Page</a><a href="http://ponx.s5.xrea.com/bibo/?date=20020329">Linuxビボ〜ろく</a><a href="http://ponx.s5.xrea.com/bibo/?date=20020329">こちら</a>:))

== 辞書ファイルフォーマットについて
辞書ファイルは必須ではありませんが、あるととても便利です。もちろん、辞書ファイルからURLを検索してアンカーを生成する場合は必須です。
辞書ファイルは以下のようなフォーマットにします。

 tDiary.Net http://www.tdiary.net/ 
 h      http://ponx.s5.xrea.com/ My Home Page 
 bibo   http://ponx.s5.xrea.com/bibo/?date= Linuxビボ〜ろく 
 users http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?  tDiary-users Project euc

Wiki等にリンクを張る際に、日本語が必要な時があります。その場合は相手先の文字コードで呼び出す必要がありますので、最後に文字コード(euc/sjis/jis)を指定します。

* 各行のフォーマットは、 キー URL 名称　文字コードです。各項目は空白で区切ります。
* 名称は省略可能です。省略した場合はキーが使われます。
* 文字コードは省略可能です。省略した場合はeucが使われます。他にsjis, jisを指定できます。
* ファイルはEUC-JPで保存します。
* 保存場所は後述の「辞書ファイルの置き場所」を参照してください。

辞書ファイルはエディタを使って直接編集しても問題ありませんが、CGI(a_conf.rb)を使ってWWWブラウザから作成・編集できます。
ここでは、それを使って辞書ファイルを作成・編集する方法を説明します。

=== ファイルの配置
必要なファイルは3つです。それぞれ以下のように配置します。

* a_conf.rb - 辞書ファイル編集CGI(本体)
  tDiary直下(tdiary.rbと同じディレクトリ)に置きます。アクセス権はindex.rb/update.rbと同じにします。
* a_conf.rhtml - 辞書ファイル編集CGI(PC用)
  skelディレクトリに置きます。

=== アクセス権の指定
a_conf.rbは、update.rb同様に、他人に編集されるのはセキュリティ上問題ですので.htaccessを使用して認証させます。

.htaccessに以下を追加します。

 <Files a_conf.rb>
   AuthName      tDiary
   AuthType      Basic
   AuthUserFile  /home/hoge/tdiary/.htpasswd
   Require user  hoge
 </Files>

=== 実行
あとは、WWWから http://www.hogehoge.com/tdiary/a_conf.rb 等としてアクセスします。

=== ナビゲーションボタンの追加
tDiaryのヘッダ/フッタのお好みの場所に以下を追加します。

 <%= navi_a %>

これで、a_conf.rbへのナビゲーションボタンが日記に追加されます。ボタン名称はデフォルトで"a.rb設定"ですが、変更可能です。変更するには以下のようにします。

 <%= navi_a "ボタン名" %>

== オプション指定
=== 辞書ファイルの置き場所
辞書ファイルはデフォルトで@data_path(tdiary.confに設定したもの)/cache/a.datに置かれます。
辞書ファイルの置き場所を変更した場合は、tdiary.confに以下のオプションを追加します。

 @options['a.path'] = "/home/hoge/diary/a.dat"

a.dat(辞書ファイル:後述)はWWW経由でアクセスできない(public_html配下でない)ディレクトリに置いた方が良いでしょう。それから、ディレクトリ・ファイルのアクセス権には注意してください。WWWサーバがRead/Writeアクセスできる必要があります。

=== tlink拡張
tDiaryプラグイン集に標準添付の((<tlink.rb|URL:http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/tdiary/plugin/tlink.rb>))を呼び出し、tlink.rbの機能である「アンカーのtitle属性値にリンク先に書いてある内容を指定する」ことができます（詳しくはtlink.rbのコメントを参照してください）。この機能を使う場合は、tlink.rbをpluginディレクトリにおいてtdiary.confに以下のオプションを追加します。

 @options['a.tlink'] = true

ただし、このオプションを有効にした場合、最初に日記を開いたときにリンク先へのアクセスが発生します(1度アクセスしたデータはキャッシュされますので2回目以降は大丈夫です)。レンタルサーバ等で使用して負荷が高くなってしまった場合はfalseにしてください。指定しない場合はfalseです。

== ライセンスについて
Copyright (C) 2002,2003 MUTOH Masao <mutoh@highwhay.ne.jp>

本ソフトウェアはGNU General Public License Version 2(GNU一般公有使用許諾書バージョン2)に基づいてリリースされるフリーソフトウェアです。
また、本プログラムは無保証です。本プログラムの利用により何らかのトラブルが生じても、当方は一切責任を負いません。

== メンテナ
本ソフトウェアについてのご意見・バグレポートは武藤まで。
MUTOH Masao <mutoh@highway.ne.jp>

=end
