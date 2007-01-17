# cocomment.rb $Revision: 1.2 $
#
# Copyright (C) 2006 by Hiroshi SHIBATA
# You can redistribute it and/or modify it under GPL2.
#
if @mode == 'day' and not bot? then
	add_footer_proc do
		<<-SCRIPT
      <script type="text/javascript">
      coco =
      {
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
      }
      <script id="cocomment-fetchlet" src="http://www.cocomment.com/js/enabler.js" type="text/javascript">
      </script>
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
