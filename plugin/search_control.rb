=begin
= ここだけ検索プラグイン/search control plugin((-$Id: search_control.rb,v 1.4 2003-10-13 14:55:24 zunda Exp $-))

== 著作権について (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

=begin ChangeLog
See ChangeLog for changes after this.

* Aug 28, 2003 zunda <zunda at freeshell.org>
- 1.3
- simpler configuration display

* Aug 26, 2003 zunda <zunda at freeshell.org>
- 1.2
- no table in configuration view, thanks to Tada-san.

* Aug 26, 2003 zunda <zunda at freeshell.org>
- no nofollow
- English translation
=end ChangeLog

# index or follow
Search_control_categories = [ 'index' ]

# [0]:index
Search_control_defaults = {
	'latest' => ['f'],
	'day' => ['t'],
	'month' => ['f'],
	'nyear' => ['f'],
	'category' => ['f'],
}

# to be used for @options and in the HTML form
Search_control_prefix = 'search_control'

# defaults
Search_control_categories.each_index do |c|
	Search_control_defaults.each_key do |view|
		cat = Search_control_categories[c]
		key = "#{Search_control_prefix}.#{view}.#{cat}"
		unless @conf[key] then
			@conf[key] = Search_control_defaults[view][c]
		end
	end
end

# configuration
add_conf_proc( Search_control_prefix, @search_control_plugin_name ) do

	# receive the configurations from the form
	if 'saveconf' == @mode then
		Search_control_categories.each do |cat|
			Search_control_defaults.each_key do |view|
				key = "#{Search_control_prefix}.#{view}.#{cat}"
				if 't' == @cgi.params[key][0] then
					@conf[key] = 't'
				else
					@conf[key] = 'f'
				end
			end
		end
	end

	# show the HTML
	case @conf.lang
	when 'en'
		r = <<-_HTML
		<p>Asks the crawlers from external search engines not to index
			unwanted pages. Check the viewes you want the search engines to
			index.</p>
		<ul>
		_HTML
		[
			[ 'Latest', 'latest' ], [ 'One-day', 'day' ], [ 'One-month', 'month' ],
			[ 'Same-day', 'nyear' ], [ 'Category', 'category' ]
		].each do |a|
			label = a[0]
			key = "#{Search_control_prefix}.#{a[1]}"
			r << <<-_HTML
				<li><input name="#{key}.index" value="t" type="checkbox"#{'t' == @conf["#{key}.index"] ? ' checked' : ''}>#{label}
			_HTML
		end
		r << "\t\t</ul>\n"
	else
		r = @search_control_description_html + "\t\t<ul>\n"
		@search_control_categorirs.each do |a|
			label = a[0]
			key = "#{Search_control_prefix}.#{a[1]}"
			r << <<-_HTML
				<li><input name="#{key}.index" value="t" type="checkbox"#{'t' == @conf["#{key}.index"] ? ' checked' : ''}>#{label}
			_HTML
		end
		r << "\t\t</ul>\n"
	end
	r

end

add_header_proc do
	# modes
	if /^(latest|day|month|nyear)$/ =~ @mode then
		key = "#{Search_control_prefix}.#{@mode}"
	elsif /^category/ =~ @mode then
		key = "#{Search_control_prefix}.category"
	else
		key = nil
	end

	# output
	if key then
		%Q|\t<meta name="robots" content="#{'f' == @conf["#{key}.index"] ? 'noindex' : 'index' },follow">\n|
	else
		''
	end
end
