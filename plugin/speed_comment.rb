# speed_comment.rb $Revision: 1.3 $
#
# spped_comment: 最新・月毎表示時に簡易なツッコミフォームを表示する
#                pluginディレクトリに入れるだけで動きます。
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#
=begin ChangeLog
2002-03-24 TADA Tadashi <sho@spc.gr.jp>
	* suppress output in mobile mode. 

2002-03-12 TADA Tadashi <sho@spc.gr.jp>
	* support insert into @header.
=end

add_body_leave_proc( Proc::new do |date|
	if /latest|month/ =~ @mode and not @cgi.mobile_agent? then
		r = ""
		r << %Q[<div class="form"><form method="post" action="] + @index + %Q["><p>]
		r << %Q[<input type="hidden" name="date" value="] + date.strftime( '%Y%m%d' ) + %Q[">]
		r << %Q[<input type="hidden" name="mail" value="">]
		r << comment_name_label + %Q[: <input class="field" name="name" value="">]
		r << comment_body_label + %Q[: <input class="field" name="body" size="40">]
		r << %Q[<input type="submit" name="comment" value="] + comment_submit_label + %Q[">]
		r << %Q[</p></form></div>]
	else
		''
	end
end )

