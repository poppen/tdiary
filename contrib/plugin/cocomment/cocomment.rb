# cocomment.rb $Revision: 1.1 $
#
# Copyright (C) 2006 by Hiroshi SHIBATA
# You can redistribute it and/or modify it under GPL2.
#
if @mode == 'day' and not bot? then
	add_footer_proc do
		<<-SCRIPT
      <script type="text/javascript"><!--
      var blogTool               = "tDiary";
      var blogURL                = "#{h @conf.base_url}";
      var blogTitle              = "#{h @conf.html_title}";
      var postURL                = document.location.href;
      var postTitle              = document.title;
      var commentAuthorFieldName = "name";
      var commentAuthorLoggedIn  = false;
      var commentFormName        = "comment-form";
      var commentTextFieldName   = "body";
      var commentButtonName      = "comment";
      // --></script>
		SCRIPT
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
