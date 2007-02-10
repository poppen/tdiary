# footnote.rb $Revision: 1.11 $
#
# fn: 脚注plugin
#   パラメタ:
#     text: 脚注本文
#     mark: 脚注マーク('*')
#
# Copyright (C) 2007 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL.

# initialize variables
add_body_enter_proc do |date|
	fn_initialize
end

add_section_enter_proc do |date, index|
	fn_initialize( index )
end

def fn_initialize( section = 1 )
	@fn_section = section
	@fn_notes = []
	@fn_marks = []
end

def fn( text, mark = '*' )
	@fn_notes << text
	@fn_marks << mark
	idx = @fn_notes.size

	r = %Q|<span class="footnote">|
	if feed? then
		r << %Q|#{mark}#{idx}|
	else
		r << %Q|<a |
		r << %Q|name="#{sprintf( 'fm%02d-%02d', @fn_section, idx )}" | if @mode == 'day'
		r << %Q|href="##{sprintf( 'f%02d-%02d', @fn_section, idx )}" |
		r << %Q|title="#{h text}">|
		r << %Q|#{mark}#{idx}|
		r << %Q|</a>|
	end
	r << %Q|</span>|
end

# print footnotes
add_section_leave_proc do |date, index|
	fn_put
end

add_body_leave_proc do |date|
	fn_put
end

def fn_put
	if @fn_notes.size > 0 then
		r = %Q|<div class="footnote">\n|
		@fn_notes.each_with_index do |fn, idx|
			r << %Q|\t<p class="footnote">|
			if feed? then
				r << %Q|#{h @fn_marks[idx]}#{idx+1}|
			else
				r << %Q|<a |
				r << %Q|name="#{sprintf( 'f%02d-%02d', @fn_section, idx+1 )}" | if @mode == 'day'
				r << %Q|href="##{sprintf( 'fm%02d-%02d', @fn_section, idx+1 )}">|
				r << %Q|#{h @fn_marks[idx]}#{idx+1}|
				r << %Q|</a>|
			end
			r << %Q|&nbsp;#{@fn_notes[idx]}</p>\n|
		end
		@fn_notes.clear
		r << %Q|</div>\n|
	else
		''
	end
end

# vim: ts=3
