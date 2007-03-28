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
	if @mode == 'day' and not @conf.mobile_agent? then
		<<-STYLE
		<style type="text/css"><!--
			form.comment div.mail { display: none; }
		--></style>
		STYLE
	else
		''
	end
end

add_footer_proc do
	if @mode == 'day' and not @conf.mobile_agent? then
		<<-SCRIPT
		<script type="text/javascript"><!--
			document.getElementsByName("mail")[0].value = "";
		//--></script>
		SCRIPT
	else
		''
	end
end

def comment_form_mobile_mail_field
	%Q|<INPUT NAME="mail" TYPE="hidden">|
end

