#
# antirefspam.rb 
#
# Copyright (c) 2004 T.Shimomura <redbug@netlife.gr.jp>
#

@antispamref_html_myurl = <<-TEXT
	<h3>許容するリンク先の指定</h3>
	<p>
	トップページURL(#{unless @conf.index_page.empty? then @conf.index_page else "未設定" end})以外にリンク先として許容するURLを指定します。
	正規表現も利用可能です。
	</p>
	TEXT

@antispamref_html_trustedurl = <<-TEXT
	<h3>信頼するリンク元の指定</h3>
	<p>
	ヒント：
	<ul>
	<li>１行に１つの URL を書いてください。</li>
	<li>\#で始まる行、空行は無視されます。</li>
	<li>"信頼するリンク元" は２段階に分けてチェックされます。</li>
	<ul>
	<li>１回目は、正規表現を使っていないものとしてチェックします。書かれた URL がリンク元に
	    含まれてさえいれば、信頼するリンク元とみなします。<br>
	    例 : リンク元が http://www.foo.com/bar/ や http://www.foo.com/baz/ の場合、
	         URL には http://www.foo.com/ と書けばよい。</li>
	<li>２回目は、正規表現を使っているものとしてチェックします。この場合、URL中 の : (コロン) と / (スラッシュ) は
	    内部でエスケープされます。正規表現を使う場合、リンク元の全体にマッチする必要がある点に注意してください。<br>
	    例 : リンク元が http://aaa.foo.com/bar/ や http://bbb.foo.com/baz/ の場合、
	         URL には http://\\w+\.foo\.com/.* と書けばよい。</li>
	</ul>
	</ul>
	</p>
	TEXT

@antispamref_html_faq = <<-TEXT
	<p>
	その他、最新のFAQは <a href="http://www.netlife.gr.jp/redbug/diary/?date=20041018\#p02">http://www.netlife.gr.jp/redbug/diary/?date=20041018\#p02</a> を参照してください。
	</p>
	TEXT

