# Japanese resource of highlight.rb
#

def highlight_conf_label; 'ハイライト'; end

def highlight_conf_html
	<<-HTML
	<h3 class="subtitle">ハイライトの色設定</h3>
	<p>ジャンプした先のサブタイトルを<span style="color: #{CGI::escapeHTML(@conf['highlight.color'])}; background: #{CGI::escapeHTML(@conf['highlight.background'])}">サンプル</span>のようにハイライトします。</p>

	<table>
		<tr>
			<th>ハイライトの文字色</th>
			<td><input name="highlight.color" value="#{CGI::escapeHTML(@conf['highlight.color'])}"></td>
		</tr>
		<tr>
			<th>ハイライトの背景色</th>
			<td><input name="highlight.background" value="#{CGI::escapeHTML(@conf['highlight.background'])}"></td>
		</tr>
	</table>
	HTML
end
