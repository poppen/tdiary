#
# youtube.rb: YouTube plugin for tDiary
#
# Copyright (C) 2007 by TADA Tadashi <sho@spc.gr.jp>
#
# usage: <%= youtube 'VIDEO_ID' %>
#
def youtube( video_id )
	<<-TAG
	<object width="425" height="350"><param name="movie" value="http://www.youtube.com/v/#{video_id}"></param><embed src="http://www.youtube.com/v/#{video_id}" type="application/x-shockwave-flash" width="425" height="350"></embed></object>
	TAG
end
