# calendar2.rb $Revision: 1.3 $
#
# calendar2: どこかで見たようなカレンダーを日記に追加する
#   パラメタ:
#     days_format: 曜日を現すStringから構成されるArray
#                  ("日月火水木金土".split(//))
#     nav_format:  カレンダー上部に表示されるStringから構成されるArray
#                  (["前", "%d年<br>%d月", "次"])
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
def calendar2_make_cal(year, month)
  result = []
  t = Time.local(year, month, 1)
  r = Array.new(t.wday, nil)
  r << 1
  2.upto(31) do |i|
    break if Time.local(year, month, i).month != month
    r << i
  end
  r += Array.new((- r.size) % 7, nil)
   0.step(r.size - 1, 7) do |i|
     result << r[i, 7]
  end
  result
end

def calendar2_prev_current_next
  yyyymm = @date.strftime "%Y%m"
  yms = [yyyymm]
  @years.keys.each do |y|
    yms |= @years[y].collect {|i| y + i}
  end
  yms.sort!
  yms.unshift nil
  yms.push nil
  i = yms.index(yyyymm)
  yms[i - 1, 3]
end

def calendar2_make_anchor(ym, str)
  if ym
    %Q|<a href="#{@index}#{anchor ym}">#{str}</a>|
  else
    str
  end
end

def calendar2(days_format = "日月火水木金土".split(//),
              nav_format = ["前", "%d年<br>%d月", "次"])
  return '' if /TAMATEBAKO/ =~ ENV["HTTP_USER_AGENT"]
  year = @date.year
  month = @date.month  
  p_c_n = calendar2_prev_current_next

  result = <<CALENDAR_HEAD
<table class="calendar" summary="calendar">
<tr>
 <td class="calendar-prev-month" colspan="2">#{calendar2_make_anchor(p_c_n[0], nav_format[0] % [year, month])}</td>
 <td class="calendar-current-month" colspan="3">#{calendar2_make_anchor(p_c_n[1], nav_format[1] % [year, month])}</td>
 <td class="calendar-next-month" colspan="2">#{calendar2_make_anchor(p_c_n[2], nav_format[2] % [year, month])}</td>
</tr>
CALENDAR_HEAD
  result << "<tr>"
  result << %Q| <td class="calendar-sunday">#{days_format[0]}</td>\n|
  1.upto(5) do |i|
    result << %Q| <td class="calendar-weekday">#{days_format[i]}</td>\n|
  end
  result << %Q| <td class="calendar-saturday">#{days_format[6]}</td>\n|
  result << "</tr>\n"
  calendar2_make_cal(year, month).each do |week|
    result << "<tr>\n"
    week.each do |day|
      if day == nil
        result << %Q| <td class="calendar-day"></td>\n|
      else
        date = "%04d%02d%02d" % [year, month, day]
        result << %Q| <td class="calendar-day">%s</td>\n| %
          if @diaries[date] == nil or ! @diaries[date].visible?
            day.to_s
          else
            subtitles = []
            idx = "01"
            @diaries[date].each_paragraph do |paragraph|
              if paragraph.subtitle
                subtitles << %Q|#{idx}. #{CGI::escapeHTML(paragraph.subtitle.gsub(/<.+?>/, ''))}|
                idx.succ!
              end
            end
            %Q|<a href="#{@index}#{anchor date}" title="#{subtitles.join("&#13;&#10;")}">#{day}</a>|
          end
      end
    end
    result << "</tr>\n"
  end
  result << "</table>\n"
end

#@calendar2_cache = CacheMonth.new(@date, :calender2, method(:calendar2))
#add_update_proc @calendar2_cache.writer

