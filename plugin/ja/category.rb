# ja/category.rb $Revision: 1.2 $
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

def category_title
	info = Category::Info.new(@cgi, @years, @conf)
	mode = info.mode
	case mode
	when :year
		period = "#{info.year}年"
	when :half
		period = (info.month.to_i == 1 ? "上半期" : "下半期")
		period = "#{info.year}年 #{period}" if info.year
	when :quarter
		period = "第#{info.month.to_i}四半期"
		period = "#{info.year}年 #{period}" if info.year
	when :month
		period = "#{info.month.to_i}月"
		period = "#{info.year}年 #{period}" if info.year
	end
	period = "(#{period})" if period

	"[#{info.category.join('|')} #{period}]"
end

def category_init_local
	@conf['category.prev_year'] ||= '&laquo;($1)'
	@conf['category.next_year'] ||= '($1)&raquo;'
	@conf['category.prev_half'] ||= '&laquo;($1-$2)'
	@conf['category.next_half'] ||= '($1-$2)&raquo;'
	@conf['category.prev_quarter'] ||= '&laquo;($1-$2)'
	@conf['category.next_quarter'] ||= '($1-$2)&raquo;'
	@conf['category.prev_month'] ||= '&laquo;($1-$2)'
	@conf['category.next_month'] ||= '($1-$2)&raquo;'
	@conf['category.this_year'] ||= '年'
	@conf['category.this_half'] ||= '半期'
	@conf['category.this_quarter'] ||= '四半期'
	@conf['category.this_month'] ||= '月'
	@conf['category.all_diary'] ||= '全期間'
	@conf['category.all_category'] ||= '全カテゴリ'
	@conf['category.all'] ||= '全期間/全カテゴリ'
end
category_init_local

@category_conf_label = 'カテゴリ'
def category_conf_html
	r = <<HTML
<h3 class="subtitle">カテゴリインデックスの作成</h3>
<p>
カテゴリ一の機能を利用するにはカテゴリインデックスをあらかじめ作成しておく必要があります．
カテゴリインデックスを作成するには
<a href="#{@conf.update}?conf=category;category_initialize=1">ここ</a>
をクリックしてください．
日記の量やサーバの性能にもよりますが，数秒から数十秒でインデックスの作成は終了します．
</p>

<h3 class="subtitle">ヘッダ</h3>
<p>
画面上部に表示する文章を指定します．
「&lt;%= category_navi %&gt;」で，カテゴリに特化したナビゲーションボタンを表示することができます．
また「&lt;%= category_list%&gt;」でカテゴリ名一覧を表示することができます．
その他，各種プラグインやHTMLを記述できます．
</p>

<p>ヘッダ1：ナビゲーションボタンのすぐ下に表示されます．</p>
<textarea name="category.header1" cols="70" rows="8">#{CGI.escapeHTML(@conf['category.header1'])}</textarea>

<p>ヘッダ2：H1のすぐ下に表示されます．</p>
<p><textarea name="category.header2" cols="70" rows="8">#{CGI.escapeHTML(@conf['category.header2'])}</textarea></p>

<h3 class="subtitle">ボタンラベル</h3>
<p>
ナビゲーションボタンのラベルを指定します．
ラベル中の$1と$2は，それぞれ「年」「月」を表す数値で置換されます．
</p>
<table border="0">
<tr><th>ボタン名</th><th>ラベル</th><th>サンプル</th></tr>
HTML
	[
		['前年', 'category.prev_year'],
		['翌年', 'category.next_year'],
		['前の半年', 'category.prev_half'],
		['次の半年', 'category.next_half'],
		['前四半期', 'category.prev_quarter'],
		['次四半期', 'category.next_quarter'],
		['先月', 'category.prev_month'],
		['翌月', 'category.next_month'],
		['今年', 'category.this_year'],
		['現半期', 'category.this_half'],
		['現四半期', 'category.this_quarter'],
		['今月', 'category.this_month'],
		['全日記', 'category.all_diary'],
		['全カテゴリ', 'category.all_category'],
		['全日記/全カテゴリ', 'category.all'],
	].each do |button, name|
		r << <<HTML
<tr>
	<td>#{button}</td>
	<td><input type="text" name="#{name}" value="#{CGI.escapeHTML(@conf[name])}" size="30"></td>
	<td><p><span class="adminmenu"><a>#{@conf[name].sub(/\$1/, "2004").sub(/\$2/, "2")}</a></span></p></td>
</tr>
HTML
	end
	r << <<HTML
</table>
HTML
end

# vim: ts=3
