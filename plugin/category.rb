# category.rb $Revision: 1.4 $
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

def category_form_year_label; "年"; end
def category_form_month_label; "月"; end
def category_form_submit_label; "カテゴリ別表示"; end

def category_form
	r = <<-FORM
		<div class="adminmenu">
		<form method="get" action="#{@index}"><div><span class="adminmenu">
		<select name="year">
	FORM
	year = @year || @date.year
	@years.keys.sort.each do |y|
		r << %Q|<option value="#{y}"#{(y == year.to_s) ? " selected" : ""}>#{y}</option>\n|
	end
	r << <<-FORM
		</select>
		#{category_form_year_label}
		<select name="month">
	FORM
	if @cgi.valid?('month')
		month = @cgi.params['month'][0]
	else
		month = "#{(@date.month - 1) / 3 + 1}Q"
	end
	["ALL", "1Q", "2Q", "3Q", "4Q"].each do |m|
		r << %Q|<option value="#{m}"#{(m == month) ? " selected" : ""}>#{m}</option>|
	end
	(1..12).each do |m|
		m = '%02d' % m
		r << %Q|<option value="#{m}"#{(m == month) ? " selected" : ""}>#{m}</option>\n|
	end
	r << <<-FORM
		</select>
		#{category_form_month_label}
		<input type="hidden" name="category" value="ALL">
		<input type="submit" value="#{category_form_submit_label}">
		</span></div></form>
		</div>
	FORM
end

def category_anchor(cname)
	if @options['category.icon'] and @options['category.icon'][cname]
		%Q|<a href="#{@index}?year=#{@date.year};month=#{(@date.month - 1) / 3 + 1}Q;category=#{CGI::escape(cname)}"><img src="#{@options['category.icon'][cname] }" alt="#{cname}"></a>|
	else
		%Q|[<a href="#{@index}?year=#{@date.year};month=#{(@date.month - 1) / 3 + 1}Q;category=#{CGI::escape(cname)}">#{cname}</a>]|
	end
end

@category_rb_installed = true
# vim: ts=3
