# navi_user.rb $Revision: 1.7 $
#
# navi_user: 前日，翌日→前の日記，次の日記
#   modeがday/commentのときに表示される「前日」「翌日」ナビゲーション
#   リンクを，「前の日記」，「次の日記」に変更するplugin．前の日記，次
#   の日記がない場合は，ナビゲーションを表示しない．月またぎにも対応．
#
#   @secure=true では動作しません．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class TDiaryMonth
	  attr_reader :diaries
	end
end
MODIFY_CLASS

def navi_user_day
	cgi = CGI.new
	def cgi.referer; nil; end
	days = []
	yms = []
	today = @date.strftime('%Y%m%d')
	this_month = @date.strftime('%Y%m')

	@years.keys.each do |y|
		yms += @years[y].collect {|m| y + m}
	end
	yms |= [this_month]
	yms.sort!
	yms.unshift(nil).push(nil)
	yms[yms.index(this_month) - 1, 3].each do |ym|
		next unless ym
		cgi.params['date'] = [ym]
		m = TDiaryMonth.new(cgi, '', @conf)
		days += m.diaries.keys.sort
	end
	days |= [today]
	days.sort!
	days.unshift(nil).push(nil)
	prev_day, cur_day, next_day = days[days.index(today) - 1, 3]

	result = ''
	result << navi_item( "#{@index}#{anchor prev_day}", "&laquo;#{navi_prev_diary(navi_user_format(prev_day))}" ) if prev_day
	result << navi_item( @index, navi_latest )
	result << navi_item( "#{@index}#{anchor next_day}", "#{navi_next_diary(navi_user_format(next_day))}&raquo;" ) if next_day
	result
end

def navi_user_format( day )
	Time::local( *day.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] )
end
