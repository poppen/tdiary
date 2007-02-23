# google_video.rb: Google Video plugin for tDiary
#
# usage: <%= google_video 'DOC_ID' %>
#
# Copyright (C) 2007 by KAKUTANI Shintaro <shintaro@kakutani.com>
# You can redistribute it and/or modify it under GPL2.
def google_video( doc_id )
   url = "http://video.google.com/googleplayer.swf?docId=#{doc_id}&hl=en"
   width, height = 425, 350
   <<-TAG
   <object width="#{width}" height="#{height}"><param name="movie" value="#{url}"></param
   ><embed src="#{url}" type="application/x-shockwave-flash" width="#{width}" height="#{height}"
   ></embed></object>
   TAG
end
