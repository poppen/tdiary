# referer-utf8.rb $Revision: 1.1 $
#
# リンク元に含まれるUTF-8の文字を、日本語とみなして適当に変換する
# pluginディレクトリに入れるだけで動作する
#
# なお、disp_referrer.rbプラグインには同等の機能が含まれているので、
# disp_referrerを導入済みの場合には入れる必要はない
#
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Modified by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
=begin ChangeLog
2003-03-28 TADA Tadashi <sho@spc.gr.jp>
	* modify disp_referer.rb.
=end

require 'uconv'
require 'nkf'

eval( <<TOPLEVEL_CLASS, TOPLEVEL_BINDING )
	def Uconv.unknown_unicode_handler( unicode )
		if unicode == 0xff5e
			"〜"
		else
			raise Uconv::Error
		end
	end

	module TDiary
		module DiaryBase
			@reg_char_utf8 = /&#[0-9]+;/
			def referers
				newer_referer
				@referers
			end
	
			def disp_referer( table, ref )
				ret = CGI::unescape( ref )
				if @reg_char_utf8 =~ ref
					ret.gsub!( @reg_char_utf8 ) do |v|
						Uconv.u8toeuc( [$1.to_i].pack( "U" ) )
					end
				else
					begin
						ret = Uconv.u8toeuc( ret )
					rescue Uconv::Error
						ret = NKF::nkf( '-e', ret )
					end
				end
				
				table.each do |url, name|
					regexp = Regexp.new( url, Regexp::IGNORECASE )
					break if ret.gsub!( regexp, name )
				end
				ret
			end
		end
	end
TOPLEVEL_CLASS

