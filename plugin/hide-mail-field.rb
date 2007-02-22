#
# hide-mail-field.rb: Hide E-mail field in TSUKKOMI form against spams.
#
# To enable this plugin effective, you have to add '@' or '.*' into E-mail
# address field in spamfilter plugin.
#
# Copyright (C) 2007 by TADA Tadahi <sho@spc.gr.jp>
# Distributed under GPL.
#
add_header_proc do
	if @mode == 'day' then
		<<-STYLE
		<style type="text/css"><!--
			form.comment div.mail { display: none; }
		--></style>
		STYLE
	else
		''
	end
end
