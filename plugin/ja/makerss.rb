# makerss.rb Japanese resources
begin
	require 'uconv'
	@makerss_encode = 'UTF-8'
	@makerss_encoder = Proc::new {|s| Uconv.euctou8( s ) }
rescue LoadError
	@makerss_encode = @conf.encoding
	@makerss_encoder = Proc::new {|s| s }
end

def makerss_tsukkomi_label( id )
	"#{id[0,4]}-#{id[4,2]}-#{id[6,2]}のツッコミ[#{id[9,2].sub( /^0/, '' )}]"
end

@makerss_conf_label = 'RSSの生成'

def makerss_conf_html
	<<-HTML
	<h3>RSSの生成</h3>
	<p>RSSは他のプログラムに読みやすい形で、日記の内容を公開します。RSSに含まれる情報はRSSリーダーで読まれたり、更新通知サイトに転載されたりして利用されています。</p>
	<ul>
	<li>RSSに<select name="makerss.hidecomment">
		<option value="f"#{@conf['makerss.hidecomment'] ? '' : ' selected'}>ツッコミの全体を含める</option>
		<option value="text"#{@conf['makerss.hidecomment'] == 'text' ? ' selected' : ''}>ツッコミの日付と投稿者だけを含める</option>
		<option value="any"#{@conf['makerss.hidecomment'] == 'any' ? ' selected' : ''}>ツッコミを含めない</option></select>
	<li>RSSに本文全体を<select name="makerss.hidecontent">
		<option value="f"#{@conf['makerss.hidecontent'] ? '' : ' selected'}>含める</option>
		<option value="t"#{@conf['makerss.hidecontent'] ? ' selected' : ''}>含めない</option></select>
	<li>RSSに含める説明を<select name="makerss.shortdesc">
		<option value="f"#{@conf['makerss.shortdesc'] ? '' : ' selected'}>できるだけ長くする</option>
		<option value="t"#{@conf['makerss.shortdesc'] ? ' selected' : ''}>最初だけにする</option></select>
      <li>「#{ comment_new }」というリンクを挿入<select name="makerss.comment_link">
		<option value="f"#{@conf['makerss.comment_link'] ? '' : ' selected'}>する</option>
		<option value="t"#{@conf['makerss.comment_link'] ? ' selected' : ''}>しない</option></select>
	</ul>
   HTML
end

@makerss_edit_label = 'ちょっとした修正(RSSを更新しない)'
