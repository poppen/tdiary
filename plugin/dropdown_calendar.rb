# dropdown_calendar2.rb $Revision: 1.2 $
#
# calendar: カレンダーをドロップダウンリストに置き換えるプラグイン
#   パラメタ: なし
#
def calendar
	result = %Q[<form method="get" action="#{@index}">\n]
	result << %Q[<div class="calendar">#{@options['dropdown_calendar.label'] || '過去の日記'}\n]
	result << %Q[<select name="date">\n]
	@years.keys.sort.reverse_each do |year|
		@years[year.to_s].sort.reverse_each do |month|
			result << %Q[<option value="#{year}#{month}">#{year}-#{month}</option>\n]
		end
	end
	result << "</select>\n"
	result << %Q[<input type="submit" value="Go">\n]
	result << "</div>\n</form>"
end
