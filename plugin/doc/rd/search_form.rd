=begin
= search_form.rb - 各種検索エンジンの検索フォーム表示プラグイン

== 機能
各種検索エンジンの検索フォームを生成します。

== 使う場所
ヘッダもしくはフッタ

== 利用方法
各パラメータの右辺値があるものはデフォルト引数です。特に変更する必要がない場合は省略可能です。

* url - 検索エンジンのURL(例：/namazu/namazu.cgi)
* button_name - ボタン名称（省略可能）
* size - テキストボックスの幅（省略可能）
* default_text - テキストボックスの初期表示文字（省略可能）

--- namazu_form(url, button_name = "Search", size = 20, default_text = "")
    Namazu用検索フォーム。urlにはnamazu.cgiのURLを指定してください。

  例： <%=namazu_form("/namazu/namazu.cgi")%>

--- googlej_form(button_name = "Google 検索", size = 20, default_text = "")
    Google用検索フォーム。

  例： <%=googlej_form%>

--- yahooj_form(button_name = "Yahoo! 検索", size = 20, default_text = "")
    Yahoo!用検索フォーム。

  例：　<%=yahooj_form%>

--- lycosj_form(button_name = " 検索 ", size = 20)
    Lycos用検索フォーム

  例: <%=lycosj_form%>

== 自分自身で検索フォームを生成する
一番手っ取り早いのは自分自身でHTMLを書いてしまうことですが(^^;)、本プラグインのメソッドを使うこともできます。

--- search_form(url, query, button_name = "Search", size = 20, default_text = "", first_form = "", last_form = "")

* url - 検索エンジンのURL(例：/namazu/namazu.cgi)
* query - テキストボックスのname属性値
* button_name - ボタン名称（省略可能）
* size - テキストボックスの幅（省略可能）
* default_text - 初期表示文字（省略可能）
* first_form - <form>タグの次の部分（省略可能）
* last_form - </form>タグの前の部分（省略可能）

== 注意点
各検索フォームは、検索エンジンを提供する各社が個人ホームページ向けに提供している検索フォームを利用しています。個人的な日記で使用することはほぼ問題ないと思います（私は解釈しています）が、気になる方は、各社のサイトで確認してください。商用で利用する場合は必ず各社に確認するようにしてください。

ちなみに、検索フォーム自体を使う場合はフリーですが、検索結果については制限する（加工等をしない、フレームで使わない、商用利用は応相談等）、とするライセンス形態が多いようです。

== ライセンスについて
Copyright (C) 2002 MUTOH Masao <mutoh@highwhay.ne.jp>

本ソフトウェアはGNU General Public License Version 2(GNU一般公有使用許諾書バージョン2)に基づいてリリースされるフリーソフトウェアです。
また、本プログラムは無保証です。本プログラムの利用により何らかのトラブルが生じても、当方は一切責任を負いません。

== メンテナ
本ソフトウェアについてのご意見・バグレポートは武藤まで。
MUTOH Masao <mutoh@highway.ne.jp>

== ChangeLog
:2002-03-24 MUTOH Masao  <mutoh@highway.ne.jp>
    * Namazu, Google, Yahoo!, Lycosの検索フォームをサポート
    * version 1.0.0

=end
