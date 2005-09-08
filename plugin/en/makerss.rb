# makerss.rb English resources
@makerss_encode = 'UTF-8'
@makerss_encoder = Proc::new {|s| s }

def makerss_tsukkomi_label( id )
	"TSUKKOMI to #{id[0,4]}-#{id[4,2]}-#{id[6,2]}[#{id[9,2].sub( /^0/, '' )}]"
end

@makerss_conf_label = 'RSS feed'

def makerss_conf_html
	<<-HTML
	<h3>RSS feed settings</h3>
	<p>RSS provides contents of your diary in a machine-readable format.
		Information in RSS is read with RSS readers and posted on other web sites.</p>
	<ul>
	<li><select name="makerss.hidecomment">
		<option value="f"#{@conf['makerss.hidecomment'] ? '' : ' selected'}>Include</option>
		<option value="text"#{@conf['makerss.hidecomment'] == 'text' ? ' selected' : ''}>Hide the text of </option>
		<option value="any"#{@conf['makerss.hidecomment'] == 'any' ? ' selected' : ''}>Ignore</option></select>
		TSUKKOMI in RSS.
	<li><select name="makerss.hidecontent">
		<option value="f"#{@conf['makerss.hidecontent'] ? '' : ' selected'}>Include</option>
		<option value="t"#{@conf['makerss.hidecontent'] ? ' selected' : ''}>Hide</option></select>
		encoded contents of your diary in RSS.
	<li>Include summary of your contents<select name="makerss.shortdesc">
		<option value="f"#{@conf['makerss.shortdesc'] ? '' : ' selected'}>as long as possible</option>
		<option value="t"#{@conf['makerss.shortdesc'] ? ' selected' : ''}>only some portion</option></select>
		in RSS.
	</ul>
	HTML
end

@makerss_edit_label = "A little modify (don't update RSS)"
