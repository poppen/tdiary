# my-ex.rb $Revision: 1.7 $
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

def my( a, str, title = nil )
	date, noise, frag = a.scan( /^(\d{8}|\d{6}|\d{4})([^\dcpt]*)?([cpt]\d\d)?/ )[0]
	anc = frag ? "#{date}#{frag}" : date
	place, frag = frag.scan( /([cpt])(\d\d)/ )[0] if frag
	if date and frag and @diaries[date] then
		if place[0] == ?p then
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
		else # comment
			com = nil
			@diaries[date].each_comment( frag.to_i ) {|c| com = c}
			if com then
				title = CGI::escapeHTML( "[#{com.name}] #{com.shorten( @conf.comment_length )}" )
			end
		end
	end
	if title then
		%Q[<a href="#{@index}#{anchor anc}" title="#{title}">#{str}</a>]
	else
		%Q[<a href="#{@index}#{anchor anc}">#{str}</a>]
	end
end

