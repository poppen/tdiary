# makerss.rb English resources
@makerss_encode = 'UTF-8'
@makerss_encoder = Proc::new {|s| s }

def makerss_tsukkomi_label( id )
	"TSUKKOMI to #{id[0,4]}-#{id[4,2]}-#{id[6,2]}[#{id[9,2].sub( /^0/, '' )}]"
end

add_conf_proc('makerss', 'RSS publication') do
	if @mode == 'saveconf'
		item = 'makerss.hidecomment'
		case @cgi.params[item][0]
		when 'f'
			@conf[item] = false
		when 'text'
			@conf[item] = 'text'
		when 'any'
			@conf[item] = 'any'
		end
		%w( makerss.hidecontent makerss.shortdesc ).each do |item|
			@conf[item] = ( 't' == @cgi.params[item][0] )
		end
	end

	<<-_HTML
	<p>Publish RSS according to the following settings.</p>
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
	_HTML
end
