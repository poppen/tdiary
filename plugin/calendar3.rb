# calendar3.rb $Revision: 1.1 $
#
# calendar3: 現在表示している月のカレンダーを表示します．
#  パラメタ: なし
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
module Calendar3
	WEEKDAY = 0
	SATURDAY = 1
	SUNDAY = 2

	STYLE = {
		WEEKDAY => "calendar-weekday",
		SATURDAY => "calendar-saturday",
		SUNDAY => "calendar-sunday",
	}

	def make_cal(year, month)
		result = []
		1.upto(31) do |i|
			t = Time.local(year, month, i)
			break if t.month != month
			case t.wday
			when 0
				result << [i, SUNDAY]
			when 1..5
				result << [i, WEEKDAY]
			when 6
				result << [i, SATURDAY]
			end
		end
		result
	end

	def prev_month(year, month)
		if month == 1
			year -= 1
			month = 12
		else
			month -= 1
		end
		[year, month]
	end

	def next_month(year, month)
		if month == 12
			year += 1
			month = 1
		else
			month += 1
		end
		[year, month]
	end

	def shorten(str, len = 120)
		lines = NKF::nkf("-e -m0 -f" + len.to_s, str.gsub(/<.+?>/, '')).split("\n")
		lines[0].concat('...') if lines[0] and lines[1]
		lines[0]
	end

	module_function :make_cal, :shorten, :next_month, :prev_month
end

def calendar3
	result = ''
	/(\d\d\d\d)(\d\d)(\d\d)/ === @diaries.keys.sort.reverse[0]
	year = $1.to_i
	month = $2.to_i
	day = $3.to_i
	result << %Q|<a href="#{@index}#{anchor "%04d%02d" % Calendar3.prev_month(year, month)}">&lt;&lt;</a>\n|
	result << "%04d/%02d/\n" % [year, month]
	#Calendar3.make_cal(year, month)[(day - num >= 0 ? day - num : 0)..(day - 1)].each do |day, kind|
	Calendar3.make_cal(year, month).each do |day, kind|
		date = "%04d%02d%02d" % [year, month, day]
		if @diaries[date].nil? or !@diaries[date].visible?
			result << %Q|<span class="#{Calendar3::STYLE[kind]}">#{day}</span>\n|
		else
			result << %Q|<span class="calendar-day" onmouseover="popup(this.childNodes(2));" onmouseout="popdown(this.childNodes(2));">\n|
			result << %Q|  <a class="#{Calendar3::STYLE[kind]}" title="|
			i = 1
			r = []
			@diaries[date].each_paragraph do |paragraph|
				if paragraph.subtitle
					r << %Q|#{i}. #{paragraph.subtitle.gsub(/<.+?>/, '')}|
				end
				i += 1
			end
			result << r.join("&#13;&#10;")
			result << %Q|" href="#{@index}#{anchor date}">#{day}</a>\n|
			unless /w3m/ === ENV["HTTP_USER_AGENT"]
				result << %Q|<div class="calendar-popup">\n|
				i = 1
				@diaries[date].each_paragraph do |paragraph|
					if paragraph.subtitle
						result << %Q|  <a href="#{@index}#{anchor "%s#p%02d" % [date, i]}" title="#{CGI::escapeHTML(Calendar3.shorten(paragraph.text))}">#{i}</a>. #{paragraph.subtitle}<br>\n|
					end
					i += 1
				end
				result << %Q|</div>\n</span>\n|
			end
		end
	end
	result << %Q|<a href="#{@index}#{anchor "%04d%02d" % Calendar3.next_month(year, month)}">&gt;&gt;</a>\n|
	result
end

add_header_proc do
    <<JAVASCRIPT
  <script language="javascript">
  function popup(element) {
      element.style.display="block";  // ポップアップを表示する
      element.parentElement.title=""; // titleポップアップを消す
  }

  function popdown(element) {
      element.style.display="none";   // ポップアップを消す
  }
</script>
JAVASCRIPT
end
