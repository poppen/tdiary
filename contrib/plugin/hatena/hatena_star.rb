#
# hatena_star.rb
#
add_header_proc do
	<<-SCRIPT
	<script type="text/javascript" src="http://s.hatena.ne.jp/js/HatenaStar.js"></script>
	<script type="text/javascript"><!--
		Hatena.Star.Token = 'ここにあなたのトークンを入力';
	--></script>
	SCRIPTend
end
