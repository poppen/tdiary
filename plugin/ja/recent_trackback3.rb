# ja/recent_trackback3.rb $Revision: 1.1 $
#
# Japanese resources for recent_trackback3.rb
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
add_conf_proc('RecentTrackBack3', '最近のTrackBack') do
	saveconf_recent_trackback3
	recent_trackback3_init

	<<-HTML
	<h3 class="subtitle">表示するTrackBackの数</h3>
	<p>最大<input name="recent_trackback3.n" value="#{@conf['recent_trackback3.n']}" size="3">件</p>
	<h3 class="subtitle">各TrackBack間に挿入する文字列</h3>
	<p><input name="recent_trackback3.sep" value="#{CGI.escapeHTML(@conf['recent_trackback3.sep'])}" size="20"></p>
	<h3 class="subtitle">日付フォーマット</h3>
	<p>使用できる'%'文字については<a href="http://www.ruby-lang.org/ja/man/index.cgi?cmd=view;name=Time#strftime">Rubyのマニュアル</a>を参照．</p>
	<p><input name="recent_trackback3.date_format" value="#{CGI.escapeHTML(@conf['recent_trackback3.date_format'])}" size="40"></p>
	<h3 class="subtitle">生成するHTMLのテンプレート</h3>
	<p>各TrackBackをどのようなHTMLで表示するかを指定します．</p>
	<textarea name="recent_trackback3.format" cols="70" rows="3">#{CGI.escapeHTML(@conf['recent_trackback3.format'])}</textarea>
	<p>テンプレート中の<em>$数字</em>はそれぞれ以下の内容で置き換えられます．必要のないものは指定しなくても構いません．</p>
	<dl>
		<dt>$1</dt><dd>インデックス．</dd>
		<dt>$2</dt><dd>そのTrackBackのURL．</dd>
		<dt>$3</dt><dd>そのTrackBackのexcerpt．</dd>
		<dt>$4</dt><dd>TrackBack送信元のサイト名と記事名．</dd>
		<dt>$5</dt><dd>TrackBack Pingを受信した時刻．「日付フォーマット」で指定した形式で表示されます．</dd>
	</dl>
	HTML
end
end
# vim: ts=3
