# calendar3.rb $Revision: 1.5 $
#
# calendar3: 現在表示している月のカレンダーを表示します．
#  パラメタ: なし
#
# tdiary.confで指定するオプション:
#   @options['calendar3.erb']
#     title属性に渡す文字列をERbLightで評価するかどうか (true/false)
#     (省略時: true) 
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
	if @options.has_key? 'calendar3.erb'
		extra_erb = @options['calendar3.erb']
	else
		extra_erb = true
	end
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
			result << %Q|<span class="calendar-day" id="target-#{day}" onmouseover="popup(document.getElementById('target-#{day}'),document.getElementById('popup-#{day}'), document.getElementById('title-#{day}'));" onmouseout="popdown(document.getElementById('popup-#{day}'));">\n|
			result << %Q|  <a class="#{Calendar3::STYLE[kind]}" title="|
			i = 1
			r = []
			@diaries[date].each_paragraph do |paragraph|
				if paragraph.subtitle
					if extra_erb
						text = ERbLight.new(paragraph.subtitle.untaint).result(binding)
					else
						text = paragraph.subtitle
					end
					r << %Q|#{i}. #{text.gsub(/<.+?>/, '')}|
				end
				i += 1
			end
			result << r.join("&#13;&#10;")
			result << %Q|" href="#{@index}#{anchor date}" id="title-#{day}">#{day}</a>\n|
			unless /w3m/ === ENV["HTTP_USER_AGENT"]
				result << %Q|  <span class="calendar-popup" id="popup-#{day}">\n|
				i = 1
				@diaries[date].each_paragraph do |paragraph|
					if paragraph.subtitle
						if extra_erb
							text = ERbLight.new(paragraph.text.untaint).result(binding)
							subtitle = ERbLight.new(paragraph.subtitle.untaint).result(binding)
						else
							text = paragraph.text
							subtitle = paragraph.subtitle
						end
						result << %Q|    <a href="#{@index}#{anchor "%s#p%02d" % [date, i]}" title="#{CGI::escapeHTML(Calendar3.shorten(text))}">#{i}</a>. #{subtitle}<br>\n|
					end
					i += 1
				end
				result << %Q|  </span>\n</span>\n|
			end
		end
	end
	result << %Q|<a href="#{@index}#{anchor "%04d%02d" % Calendar3.next_month(year, month)}">&gt;&gt;</a>\n|
	result
end

add_header_proc do
    <<JAVASCRIPT
  <script language="javascript">
  // http://www.din.or.jp/~hagi3/JavaScript/JSTips/Mozilla/
  // _dom : kind of DOM.
  //        IE4 = 1, IE5+ = 2, NN4 = 3, NN6+ = 4, others = 0
  _dom = document.all?(document.getElementById?2:1)
                     :(document.getElementById?4
                     :(document.layers?3:0));

  function moveDivTo(div,left,top){
    if(_dom==4){
      div.style.left=left+'px';
      div.style.top =top +'px';
      return;
    }
    if(_dom==2 || _dom==1){
      div.style.pixelLeft=left;
      div.style.pixelTop =top;
      return;
    }
    if(_dom==3){
      div.moveTo(left,top);
      return;
    }
  }

  function moveDivBy(div,left,top){
    if(_dom==4){
      div.style.left=div.offsetLeft+left;
      div.style.top =div.offsetTop +top;
      return;
    }
    if(_dom==2){
      div.style.pixelLeft=div.offsetLeft+left;
      div.style.pixelTop =div.offsetTop +top;
      return;
    }
    if(_dom==1){
      div.style.pixelLeft+=left;
      div.style.pixelTop +=top;
      return;
    }
    if(_dom==3){
      div.moveBy(left,top);
      return;
    }
  }

  function getDivLeft(div){
    if(_dom==4 || _dom==2) return div.offsetLeft;
    if(_dom==1)            return div.style.pixelLeft;
    if(_dom==3)            return div.left;
    return 0;
  }

  function getDivTop(div){
    if(_dom==4 || _dom==2) return div.offsetTop;
    if(_dom==1)            return div.style.pixelTop;
    if(_dom==3)            return div.top;
    return 0;
  }

  function getDivWidth (div){
    if(_dom==4 || _dom==2) return div.offsetWidth;
    if(_dom==1)            return div.style.pixelWidth;
    if(_dom==3)            return div.clip.width;
    return 0;
  }

  function getDivHeight(div){
    if(_dom==4 || _dom==2) return div.offsetHeight;
    if(_dom==1)            return div.style.pixelHeight;
    if(_dom==3)            return div.clip.height;
    return 0;
  }

  function popup(target,element,notitle) {
    if (navigator.appName=='Microsoft Internet Explorer') {
      moveDivTo(element,getDivLeft(target)+getDivWidth(target),getDivTop(target)+getDivHeight(target)*13/8);
    } else {
      moveDivTo(element,getDivLeft(target)+getDivWidth(target)/2,getDivTop(target)+(getDivHeight(target)*2)/3);
    }
    element.style.display="block";
    notitle.title="";
  }

  function popdown(element) {
    element.style.display="none";
  }
</script>
JAVASCRIPT
end
