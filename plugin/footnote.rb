# footnote.rb $Revision: 1.2 $
#
# fn: 脚注plugin
#   パラメタ:
#     text: 脚注本文
#     mark: 脚注マーク('*')
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL

def fn(text, mark = '*')
	if @footnote_name
		@footnote_index += 1
		@footnotes << [@footnote_index, text, mark]
		%Q|<span class="footnote"><a name="#{@footnote_mark_name % @footnote_index}" href="#{@footnote_url % @footnote_index}">#{mark}#{@footnote_index}</a></span>|
	else
 		""
	end
end

add_body_enter_proc(Proc.new do |date|
	date = date.strftime("%Y%m%d")
	@footnote_name = "f%02d"
	@footnote_url = "#{@index}#{anchor date}##{@footnote_name}"
	@footnote_mark_name = "fm%02d"
	@footnote_mark_url = "#{@index}#{anchor date}##{@footnote_mark_name}"
	@footnotes = []
	@footnote_index = 0
	""
end)

add_body_leave_proc(Proc.new do |date|
	if @footnote_name and @footnotes.size > 0
		%Q|<div class="footnote">\n| +
		@footnotes.collect do |fn|
			%Q|  <p class="footnote"><a name="#{@footnote_name % fn[0]}" href="#{@footnote_mark_url % fn[0]}">#{fn[2]}#{fn[0]}</a>&nbsp;#{fn[1]}</p>|
		end.join("\n") +
		%Q|\n</div>\n|
	else
		""
	end
end)
