# whatsnew.rb $Revision: 1.1 $
#
# 名称：
# What's Newプラグイン
#
# 概要：
# 未読のセクションに指定したマークをつけることができます．
#
# 使い方：
# tdiary.conf の @section_anchor を以下のようにします．
#
#   @section_anchor = '<span class="sanchor"><%= whats_new %></span>'
#
# セクションの未読/既読によって <%= whats_new %> の部分があらかじめ指
# 定したマークで置き換えられます．デフォルトでは未読セクションでは
# "!!!NEW!!!"，既読セクションでは "_" に展開されます．
#
# 置き換えられる文字列を変更したい場合は tdiary.conf 中で
#
#   @options['whats_new.new_mark'] = '<img src="/Images/new.png" alt="NEW!" border="0">'
#   @options['whats_new.read_mark'] = '既'
#
# のように指定します．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

@whats_new = {}.taint

def whats_new
	return @whats_new[:read_mark] unless @cgi
	@whats_new[:section] += 1
	t = @whats_new[:current_date] + "%03d" % @whats_new[:section]
	if t > @whats_new[:this_time]
		@whats_new[:this_time] = t
	end
	# 初回もしくは cookie を使わない設定の場合は機能しない
	return @whats_new[:read_mark] if @whats_new[:last_time] == "00000000000"
	if t > @whats_new[:last_time]
		@whats_new[:new_mark]
	else
		@whats_new[:read_mark]
	end
end

add_body_enter_proc do |date|
	if @cgi
		@whats_new[:current_date] = Time::at(date).strftime('%Y%m%d')
		@whats_new[:section] = 0
		@whats_new[:last_time]
	end
	""
end

add_header_proc do
	if @cgi
		if @cgi.cookies['tdiary_whats_new'][0]
			@whats_new[:this_time] = @whats_new[:last_time] = @cgi.cookies['tdiary_whats_new'][0]
		else
			# 初めて，もしくは cookie は使わない設定
			@whats_new[:this_time] = @whats_new[:last_time] = "00000000000"
		end
		@whats_new[:new_mark] = @options['whats_new.new_mark'] || '!!!new!!!'
		@whats_new[:read_mark] = @options['whats_new.read_mark'] || '_'
	end
	""
end

add_footer_proc do
	if @cgi
		if @whats_new[:this_time] > @whats_new[:last_time]
			cookie_path = File::dirname(@cgi.script_name)
			cookie_path += '/' if cookie_path !~ /\/$/
			cookie = CGI::Cookie::new({
				'name' => 'tdiary_whats_new',
				'value' => [@whats_new[:this_time]],
				'path' => cookie_path,
				'expires' => Time::now.gmtime + 90*24*60*60 
			})
			add_cookie(cookie)
		end
	end
	""
end
# vim: ts=3
