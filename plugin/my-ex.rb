# my-ex.rb $Revision: 1.12 $
#
# my(拡張版): myプラグインを拡張し、title属性に参照先の内容を挿入します。
#             参照先がセクションの場合は(あれば)サブタイトルを、
#             ツッコミの場合はツッコんだ人の名前と内容の一部を使います。
# パラメタ:
#   a:   自分の日記内のリンク先情報('YYYYMMDD#pNN' または 'YYYYMMDD#cNN')
#   str: リンクにする文字列
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL

unless @conf.mobile_agent?

def my( a, str, title = nil )
	date, noise, frag = a.scan( /^(\d{4}|\d{6}|\d{8})([^\d]*)?#?([pct]\d\d)?$/ )[0]
	anc = frag ? "#{date}#{frag}" : date
	place, frag = frag.scan( /([cpt])(\d\d)/ )[0] if frag
	if date and frag and @diaries[date] then
		case place
		when 'p'
			section = nil
			idx = 1
			@diaries[date].each_section do |s|
				section = s
				break if idx == frag.to_i 
				idx += 1
			end
			if section and section.subtitle then
				title = CGI::escapeHTML( "#{apply_plugin(section.subtitle_to_html, true)}" )
			end
		when 'c'
			com = nil
			@diaries[date].each_comment( frag.to_i ) {|c| com = c}
			if com then
				title = CGI::escapeHTML( "[#{com.name}] #{com.shorten( @conf.comment_length )}" )
			end
		when 't'
			if @plugin_files.grep(/tb-show.rb\z/)
				tb = nil
				@diaries[date].each_visible_trackback( frag.to_i ) {|t, idx| tb = t}
				if tb then
					url, name, tbtitle, excerpt = tb.body.split( /\n/,4 )
					title = CGI::escapeHTML( "[#{name}] #{@conf.shorten( excerpt, @conf.comment_length )}" )
				end
			end
		end
	end
	if title then
		%Q[<a href="#{@index}#{anchor anc}" title="#{title}">#{str}</a>]
	else
		%Q[<a href="#{@index}#{anchor anc}">#{str}</a>]
	end
end

end
