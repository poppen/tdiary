# Japanese resource of highlight.rb
#

def highlight_conf_label; 'Highlight'; end

def highlight_conf_html
	<<-HTML
	<h3 class="subtitle">Color Settings of Highlight</h3>
	<p>Highlights subtitle jumped from other pages as <span style="color: #{CGI::escapeHTML(@conf['highlight.color'])}; background: #{CGI::escapeHTML(@conf['highlight.background'])}">THIS</span>.</p>

	<table>
		<tr>
			<th>Text color of highlight</th>
			<td><input name="highlight.color" value="#{CGI::escapeHTML(@conf['highlight.color'])}"></td>
		</tr>
		<tr>
			<th>Background color of highlight</th>
			<td><input name="highlight.background" value="#{CGI::escapeHTML(@conf['highlight.background'])}"></td>
		</tr>
	</table>
	HTML
end
