#
# linkcheck.rb: tDiary filter for checking link to my site in TrackBack source site.
#
# usage: copy this file into tdiary/fiter/. require ruby 1.8.2 or later.
#
# specification:
#    * if source site has no URI of my site of top page, it's spam!
#    * reading only top of 100KB of source site.
#    * no response over 10 sec, it's mybe spam.
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp> 2005.
# Distributed under GPL2.
#
require 'open-uri'
require 'timeout'

module TDiary
	module Filter
		class LinkcheckFilter < Filter
			def comment_filter( diary, comment )
				# check only TrackBack
				return true unless comment.name == 'TrackBack'

				dest_uri = @conf.index.dup
				dest_uri[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
				dest_uri.gsub!( %r|/\./|, '/' )

				# TrackBack URI is the 1st line of comment.body.
				src_uri, = comment.body.split( /\n/ )
				return false unless %r|^https?://|i =~ src_uri # BAD TrackBack

				begin
					Timeout::timeout( 10 ) do
		      		open( src_uri ) do |f|
							if f.read( 100 * 1024 ).include?( dest_uri ) then
								return true
							else
								return false
							end
						end
					end
				rescue Timeout::Error
					return false
				end
			end
		end
	end
end
