# makerss.rb English resources
@makerss_encode = 'UTF-8'
@makerss_encoder = Proc::new {|s| s }

def makerss_tsukkomi_label( id )
	"TSUKKOMI to #{id[0,4]}-#{id[4,2]}-#{id[6,2]}[#{id[9,2].sub( /^0/, '' )}]"
end

add_conf_proc('makerss', 'RSS publication') do
	%w( makerss.hidecomment makerss.hidecontent makerss.shortdesc ).each do |item|
		@conf[item] = ( 't' == @cgi.params[item][0] )
	end

	<<-_HTML
	<p>Publish RSS according to the following settings.</p>
	<p>RSS provides contents of your diary in a machine-readable format.
		Information in RSS is read with RSS readers and posted on other web sites.</p>
	<ul>
	<li><select name="makerss.hidecomment">
		<option value="f"#{@conf['makerss.hidecomment'] ? '' : ' selected'}>Include</option>
		<option value="t"#{@conf['makerss.hidecomment'] ? ' selected' : ''}>Hide</option></select>
		TSUKKOMI text in RSS.
	<li><select name="makerss.hidecontent">
		<option value="f"#{@conf['makerss.hidecontent'] ? '' : ' selected'}>Include</option>
		<option value="t"#{@conf['makerss.hidecontent'] ? ' selected' : ''}>Hide</option></select>
		encoded contents of your diary in RSS.
	<li>Include summary of your contens<select name="makerss.shortdesc">
		<option value="f"#{@conf['makerss.shortdesc'] ? '' : ' selected'}>as long as possible</option>
		<option value="t"#{@conf['makerss.shortdesc'] ? ' selected' : ''}>only some portion</option></select>
		in RSS.
	</ul>
	_HTML
end
