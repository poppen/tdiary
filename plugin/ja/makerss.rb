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

add_conf_proc('makerss', 'RSSの作成') do
	%w( makerss.hidecomment makerss.hidecontent makerss.shortdesc ).each do |item|
		@conf[item] = ( 't' == @cgi.params[item][0] )
	end

	<<-_HTML
	<p>下記の設定でRSSを作ります。</p>
	<p>RSSは他のプログラムに読みやすい形で、日記の内容を公開します。RSSに含まれる情報はRSSリーダーで読まれたり、更新通知サイトに転載されたりして利用されています。</p>
	<ul>
	<li>RSSにツッコミの文章を<select name="makerss.hidecomment">
		<option value="f"#{@conf['makerss.hidecomment'] ? '' : ' selected'}>含める</option>
		<option value="t"#{@conf['makerss.hidecomment'] ? ' selected' : ''}>含めない</option></select>
	<li>RSSに本文全体を<select name="makerss.hidecontent">
		<option value="f"#{@conf['makerss.hidecontent'] ? '' : ' selected'}>含める</option>
		<option value="t"#{@conf['makerss.hidecontent'] ? ' selected' : ''}>含めない</option></select>
	<li>RSSに含める説明を<select name="makerss.shortdesc">
		<option value="f"#{@conf['makerss.shortdesc'] ? '' : ' selected'}>できるだけ長くする</option>
		<option value="t"#{@conf['makerss.shortdesc'] ? ' selected' : ''}>最初だけにする</option></select>
	</ul>
	_HTML
end
