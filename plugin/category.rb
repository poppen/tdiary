# category.rb $Revision: 1.19 $
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'

#
# initialize
#
def category_init
	@conf['category.header1'] ||= %Q[<div class="adminmenu">\n<p>\n<%= category_navi %>\n</p>\n</div>\n]
	@conf['category.header2'] ||= %Q[<p>Categories |\n<%= category_list %>\n</p>\n]
	@conf['category.edit_support'] = true if @conf['category.edit_support'].nil?
end
category_init

def category_icon_location_init
	@category_icon_dir = (@conf['category.icon_dir'] || './icons/').sub(%r|/*$|, '/')
	@category_icon_url = (@conf['category.icon_url'] || './icons/').sub(%r|/*$|, '/')
end

def category_icon_init
	category_icon_location_init
	@conf['category.icon'] ||= ''

	@category_icon = {}
	@conf['category.icon'].split(/\n/).each do |l|
		c, i = l.split
		next if c.nil? or i.nil?
		@category_icon[c] = i if File.exists?("#{@category_icon_dir}#{i}")
	end
end
category_icon_init

#
# plugin methods
#
def category_form
	# don't you need this method any more?
end

def category_anchor(category)
	period = @conf['category.period'] || 'quarter'
	period_string = 
		case period
		when "month"
			"year=#{@date.year};month=#{@date.month};"
		when "quarter"
			"year=#{@date.year};month=#{(@date.month - 1) / 3 + 1}Q;"
		when "half"
			"year=#{@date.year};month=#{(@date.month - 1) / 6 + 1}H;"
		when "year"
			"year=#{@date.year};"
		else
			""
		end
	if @category_icon[category]
		%Q|<a href="#{@index}?#{period_string}category=#{CGI::escape(category)}"><img class="category" src="#{@category_icon_dir}#{@category_icon[category]}" alt="#{category}"></a>|
	else
		%Q|[<a href="#{@index}?#{period_string}category=#{CGI::escape(category)}">#{category}</a>]|
	end
end

def category_navi_anchor(info, label)
	((!label.nil?) && label.empty?) ? '' : %Q[<span class="adminmenu">#{info.make_anchor(label)}</span>\n]
end

def category_navi
	info = Category::Info.new(@cgi, @years, @conf)
	mode = info.mode

	result = ''
	case mode
	when :year, :half, :quarter, :month
		all_diary = Category::Info.new(@cgi, @years, @conf, :year => -1, :month => -1)
		all = Category::Info.new(@cgi, @years, @conf, :category => ['ALL'], :year => -1, :month => -1)
		result << category_navi_anchor(info.prev, @conf['category.prev_' + mode.to_s])
		result << category_navi_anchor(info.next, @conf['category.next_' + mode.to_s])
		result << category_navi_anchor(all_diary, @conf['category.all_diary'])
		result << category_navi_anchor(all, @conf['category.all'])
	when :all
		year = Category::Info.new(@cgi, @years, @conf, :year => Time.now.year.to_s)
		half = Category::Info.new(@cgi, @years, @conf, :year => Time.now.year.to_s, :month => "#{((Time.now.month - 1) / 6 + 1)}H")
		quarter = Category::Info.new(@cgi, @years, @conf, :year => Time.now.year.to_s, :month => "#{((Time.now.month - 1) / 3 + 1)}Q")
		month = Category::Info.new(@cgi, @years, @conf, :year => Time.now.year.to_s, :month => '%02d' % Time.now.month)
		result << category_navi_anchor(year, @conf['category.this_year'])
		result << category_navi_anchor(half, @conf['category.this_half'])
		result << category_navi_anchor(quarter, @conf['category.this_quarter'])
		result << category_navi_anchor(month, @conf['category.this_month'])
	end
	if !info.category.include?('ALL')
		all_category = Category::Info.new(@cgi, @years, @conf, :category => ['ALL'])
		result << category_navi_anchor(all_category, @conf['category.all_category'])
	end
	result
end

def category_list_sections
	info = Category::Info.new(@cgi, @years, @conf)
	category = info.category
	years = info.years
	r = ''

	@categorized.keys.sort.each do |c|
		info.category = c
		if @category_icon[c]
			img = %Q|<img class="category" src="#{@category_icon_dir}#{@category_icon[c]}" alt="#{c}">|
		else
			img = ''
		end
		r << <<HTML
<div class="conf day">
	<h2><span class="title">#{img}#{info.make_anchor}</span></h2>
	<div class="body">
		<p>
HTML
		@categorized[c].keys.sort.each do |ymd|
			text = Time.local(ymd[0,4], ymd[4,2], ymd[6,2]).strftime(@conf.date_format)
			@categorized[c][ymd].sort.each do |idx, title, excerpt|
				r << %Q|\t\t\t<a href="#{@conf.index}#{anchor "#{ymd}#p#{'%02d' % idx}"}" title="#{excerpt}">#{text}#p#{'%02d' % idx}</a> #{apply_plugin(title)}<br>\n|
			end
		end
		r << <<HTML
		</p>
	</div>
</div>
HTML
	end
	r
end

def category_list
	info = Category::Info.new(@cgi, @years, @conf)
	@categories.map do |c|
		info.category = c
		info.make_anchor
	end.join(" | \n")
end

def category_dropdown_list(label = nil, multiple = nil)
	label ||= 'Categorize!'
	multiple ||= false

	category = Category::Info.new(@cgi, @years, @conf).category
	category = ['ALL'] if category.empty?

	options = ''
	(['ALL'] + @categories).each do |c|
		options << %Q|\t\t<option value="#{CGI.escapeHTML(c)}"#{" selected" if category.include?(c)}>#{CGI.escapeHTML(c)}</option>\n|
	end

	<<HTML
<form method="get" action="#{@conf.index}?#{period_string}">
	<select name="category"#{" multiple" if multiple}>
#{options}
	</select>
	<input type="submit" value="#{label}">
</form>
HTML
end


#
# misc
#
::TDiary::TDiaryMonth.module_eval do
	attr_reader :diaries
end

def category_icon_save
	@conf['category.icon'] = @category_icon.map {|c, i| "#{c} #{i}"}.join("\n")
end


module Category

#
# Info
#
class Info
	def initialize(cgi, years, conf, args = {})
		@cgi = cgi
		@years = years
		@conf = conf
		@category = args[:category] || @cgi.params['category']
		@year = args[:year] || @cgi.params['year'][0]
		@month = args[:month] || @cgi.params['month'][0]
		@mode = :all
		set_mode
	end

protected
	attr_writer :year
	attr_writer :month
public
	attr :category, true
	attr_reader :year
	attr_reader :month
	attr_reader :mode

	def prev
		pp = self.dup

		case mode
		when :half
			h = @month.to_i
			if h == 1
				pp.month = "2H"
				pp.year = (@year.to_i - 1).to_s if @year
			else
				pp.month = "1H"
			end
		when :quarter
			q = @month.to_i
			if q == 1
				pp.month = "4Q"
				pp.year = (@year.to_i - 1).to_s if @year
			else
				pp.month = "#{q - 1}Q"
			end
		when :month
			m = @month.to_i
			if m == 1
				pp.month = "12"
				pp.year = (@year.to_i - 1).to_s if @year
			else
				pp.month = '%02d' % (m - 1)
			end
		when :year
			pp.year = (@year.to_i - 1).to_s
		end
		pp
	end

	def next
		pp = self.dup

		case mode
		when :half
			h = @month.to_i
			if h == 2
				pp.month = "1H"
				pp.year = (@year.to_i + 1).to_s if @year
			else
				pp.month = "2H"
			end
		when :quarter
			q = @month.to_i
			if q == 4
				pp.month = "1Q"
				pp.year = (@year.to_i + 1).to_s if @year
			else
				pp.month = "#{q + 1}Q"
			end
		when :month
			m = @month.to_i
			if m == 12
				pp.month = "01"
				pp.year = (@year.to_i + 1).to_s if @year
			else
				pp.month = '%02d' % (m + 1)
			end
		when :year
			pp.year = (@year.to_i + 1).to_s
		end
		pp
	end

	def make_anchor(label = nil)
		a = @category.map {|c| "category=#{CGI.escape(c)}"}.join(';')
		a << ";year=#{@year}" if @year
		a << ";month=#{@month}" if @month
		if label
			case mode
			when :year
				label = label.gsub(/\$1/, @year)
			when :month, :quarter, :half
				label = label.gsub(/\$2/, @month)
				label = label.gsub(/\$1/, @year || '*')
			end
		else
			label = @category.map {|c| CGI.escapeHTML(c)}.join(':')
		end
		%Q|<a href="#{@conf.index}?#{a}">#{label}</a>|
	end

	#
	# return ym_spec
	#
	# {"yyyy" => ["mm", ...], ...}
	#
	# date spec:
	#  (1) none               -> all diary
	#  (2) month=xH           -> all diary in xH of all year
	#  (3) year=YYYY;month=xH -> all diary in YYYY/xH
	#  (4) month=xQ           -> all diary in xQ of all year
	#  (5) year=YYYY;month=xQ -> all diary in YYYY/xQ
	#  (6) month=MM           -> all diary in MM of all year
	#  (7) year=YYYY;month=MM -> all diary in YYYY/MM
	#  (8) year=YYYY          -> all diary in YYYY
	#
	def years
		if @mode == :all
			return @years
		end

		months = case @mode
		when :half
			[('01'..'06'), ('07'..'12')][@month.to_i - 1].to_a
		when :quarter
			[['01', '02', '03'], ['04', '05', '06'], ['07', '08', '09'], ['10', '11', '12']][@month.to_i - 1]
		when :month
			[@month]
		else
			('01'..'12').to_a
		end

		r = {}
		(@year ? [@year] : @years.keys).each do |y|
			r[y] = months
		end
		r
	end

	#
	# date spec:
	#  (1) none                -> all
	#  (2) month=xH            -> half
	#  (3) year=YYYY;month=xH  -> half
	#  (4) month=xQ            -> quarter
	#  (5) year=YYYY;month=xQ  -> quarter
	#  (6) month=MM            -> month
	#  (7) year=YYYY;month=MM  -> month
	#  (8) year=YYYY           -> year
	#
	def set_mode
		if @year.nil? and @month.nil?
			@mode = :all
		end

		if /\d{4}/ === @year.to_s
			@mode = :year
		else
			@year = nil
		end

		if /[12]H/ === @month.to_s
			@mode = :half
		elsif /[1-4]Q/ === @month.to_s
			@mode = :quarter
		elsif (1..12).include?(@month.to_i)
			@mode = :month
		else
			@month = nil
		end

	end
end

#
# Cache
#
class Cache
	def initialize(conf, bind)
		@conf = conf
		@binding = bind                           # ...... very ugly
		@dir = "#{conf.data_path}/category"
		Dir.mkdir(@dir) unless File.exist?(@dir) 
	end

	def add_categories(list)
		return if list.nil? or list.empty?
		replace_categories(restore_categories + list)
	end

	def replace_categories(list)
		PStore.new(cache_file).transaction do |db|
			db['category'] = list.sort.uniq
		end
	end

	#
	# restore category names
	# ["category1", "category2", ...]
	#
	def restore_categories
		list = nil
		PStore.new(cache_file).transaction do |db|
			list = db['category'] if db.root?('category')
			db.abort
		end
		list || []
	end

	#
	# cache each section of diary
	# used in update_proc
	#
	def replace_sections(diary)
		return if diary.nil? or !diary.categorizable?

		categorized = categorize_diary(diary)
		categories = restore_categories
		deleted = []
		ymd = diary.date.strftime('%Y%m%d')

		categories.each do |c|
			PStore.new(cache_file(c)).transaction do |db|
				db['category'] = {} unless db.root?('category')
				if diary.visible? and categorized[c]
					db['category'].update(categorized[c])
				else
					# diary is invisible or sections of this category is deleted
					db['category'].delete(ymd)
					deleted << c if db['category'].empty?
				end
			end
		end

		if !deleted.empty?
			deleted.each do |c|
				File.unlink(cache_file(c))
			end
			replace_categories(categories - deleted)
		end
	end

	#
	# (re)create category cache
	#
	def recreate(years)
		cgi = CGI::new
		def cgi.referer; nil; end

		list = []
		years.each do |y, ms|
			ms.each do |m|
				ym = "#{y}#{m}"
				cgi.params['date'] = [ym]
				m = TDiaryMonth.new(cgi, '', @conf)
				sections = {}
				m.diaries.each do |ymd, diary|
					next if !diary.visible?
					initial_replace_sections(diary)
					diary.each_section do |s|
						list |= s.categories unless s.categories.empty?
					end
				end
			end
		end

		replace_categories(list)
	end

	#
	# categorize sections of category of years
	#
	# {"category" => {"yyyymmdd" => [[idx, title, excerpt], ...], ...}, ...}
	#
	def categorize(category, years)
		categories = category - ['ALL']
		if categories.empty?
			categories = restore_categories
		else
			categories &= restore_categories
		end

		categorized = {}
		categories.each do |c|
			PStore.new(cache_file(c)).transaction do |db|
				categorized[c] = db['category']
				db.abort
			end
			categorized[c].keys.each do |ymd|
				y, m = ymd[0,4], ymd[4,2]
				if years[y].nil? or !years[y].include?(m)
					categorized[c].delete(ymd)
				end
			end
			categorized.delete(c) if categorized[c].empty?
		end

		categorized
	end

private
	def cache_file(category = nil)
		if category
			"#{@dir}/#{CGI.escape(category)}".untaint
		else
			"#{@dir}/category_list"
		end
	end

	#
	# categorize sections of diary
	#
	# {"category" => {"yyyymmdd" => [[idx, title, excerpt], ...]}}
	#
	def categorize_diary(diary)
		categorized = {}
		ymd = diary.date.strftime('%Y%m%d')

		idx = 1
		diary.each_section do |s|
			s.categories.each do |c|
				categorized[c] = {} if categorized[c].nil?
				categorized[c][ymd] = [] if categorized[c][ymd].nil?
				body = <<EVAL
text = apply_plugin(<<'BODY', true)
#{s.body_to_html}
BODY
EVAL
				shorten = begin
					@conf.shorten(eval(body.untaint, @binding))
				rescue NameError
					""
				end
				categorized[c][ymd] << [idx, s.stripped_subtitle_to_html, shorten]
			end
			idx +=1
		end

		categorized
	end

	#
	# cache each section of diary
	# used in recreate
	#
	def initial_replace_sections(diary)
		return if diary.nil? or !diary.visible? or !diary.categorizable?

		categorized = categorize_diary(diary)
		categorized.keys.each do |c|
			PStore.new(cache_file(c)).transaction do |db|
				db['category'] = {} unless db.root?('category')
				db['category'].update(categorized[c])
			end
		end
	end
end

end # module Category

# read cache here so that you can use category with secure mode.
@category_cache = Category::Cache.new(@conf, binding)

#
# display categories you use on update form
#
@conf['category.edit_support'] and add_edit_proc do |date|
	ret = ''
	unless @categories.size == 0 then
		ret << %Q[
		<script type="text/javascript">
		<!--
		function inj_c(val){
			target = window.document.forms[0].body
			target.focus();
			target.value += val
		}
		//-->
		</script>
		]
		ret << '<div class="field title">'
		ret << "#{@category_conf_label}:\n"
		@categories.each do |c|
			e_c = CGI.escapeHTML(c)
			ret << %Q!| <a href="javascript:inj_c(&quot;[#{e_c}] &quot;)">#{e_c}</a>\n!
		end
		ret << "|\n</div>\n<br>\n"
	end
end


#
# when update diary, update cache
#
add_update_proc do
	cache = @category_cache
	list = []
	diary = @diaries[@date.strftime('%Y%m%d')]
	diary.each_section do |s|
		list |= s.categories
	end
	cache.add_categories(list)
	cache.replace_sections(diary)
end


#
# configuration
#
def category_icon_find_icons
   return if @category_all_icon
	@category_all_icon = []
	%w(png jpg gif bmp).each do |e|
		@category_all_icon += Dir.glob("#{@category_icon_dir}*.#{e}").map {|i| File.basename(i)}
	end
	@category_all_icon.sort!
end

def category_icon_select(category)
	options = %Q|<\t<option value="none">#{@category_icon_none_label}</option>\n|
	@category_all_icon.each do |i|
		options << %Q|\t<option value="#{CGI.escapeHTML(i)}"#{" selected" if @category_icon[category] == i}>#{CGI.escapeHTML(i)}</option>\n|
	end
	<<HTML
<select name="category.icon.#{category}">
#{options}
</select>
HTML
end

def category_icon_sample
	@category_all_icon.map do |i|
		%Q|<img src="#{@category_icon_url}#{i}" alt="#{i}">\n|
	end.join("/\n")
end

if @mode == 'conf' || @mode == 'saveconf'
	add_conf_proc('category', @category_conf_label) do
		cache = @category_cache
		if @mode == 'saveconf'
			[
				'category.header1',
				'category.header2',
			].each do |name|
				@conf[name] = @conf.to_native( @cgi.params[name][0] )
			end
			[
				'category.prev_year',
				'category.next_year',
				'category.prev_half',
				'category.next_half',
				'category.prev_quarter',
				'category.next_quarter',
				'category.prev_month',
				'category.next_month',
				'category.this_year',
				'category.this_half',
				'category.this_quarter',
				'category.this_month',
				'category.all_diary',
				'category.all_category',
				'category.all',
			].each do |name|
				@conf[name] = @conf.to_native( @cgi.params[name][0] )
			end
			if ["month", "quearter", "half", "year", "all"].index(@cgi.params["category.period"][0])
				@conf["category.period"] = @cgi.params["category.period"][0]
			end
			@conf['category.edit_support'] = (@cgi.params['category.edit_support'][0] == 'true')
		end
		category_conf_html
	end

	category_icon_find_icons if @cgi.params['conf'][0] == 'category_icon'
	add_conf_proc('category_icon', @category_icon_conf_label) do
		if @mode == 'saveconf'
			unless @conf.secure
				[
					'category.icon_dir',
					'category.icon_url',
				].each do |name|
					@conf[name] = @cgi.params[name][0].sub(%r|/*$|, '/')
				end
				category_icon_location_init
			end
			@cgi.params.keys.each do |key|
				next unless /\Acategory\.icon\..*\z/ === key
				category = key.sub(/\Acategory\.icon\./, '')
				@category_icon[category] = @cgi.params[key][0] if @cgi.params[key][0] != 'none'
			end
			category_icon_save
		end
		category_icon_conf_html
	end
	if @cgi.valid?('category_initialize')
		@category_cache.recreate(@years)
	end
end

@categories = @category_cache.restore_categories
if @mode == 'categoryview'
	info = Category::Info.new(@cgi, @years, @conf)
	@categorized = @category_cache.categorize(info.category, info.years)
end

# vim: ts=3
