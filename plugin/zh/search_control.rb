=begin
= Search control plugin((-$Id: search_control.rb,v 1.1 2004-06-15 15:19:21 tadatadashi Exp $-))
English resource

== Usage
Put this file into the plugin/ directory or select this plugin by the
plugin selection plugin.

To set up, click `Search control' in the configuration view. You can
choose if you want crawlers from external search engines to index your
one-day view, latest view, etc. The default is to ask the crawlers to
only index one-day view.

To this plugin to take effect, we have to wish that the crawlers regards
the meta-tag.

This plugin also works in a diary with @secure = true.

== Copyright notice
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

=begin ChangeLog
See ../ChangeLog for changes after this.

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

# configuration
@search_control_plugin_name = 'Search control'
@search_control_description_html = <<-'_HTML'
	<p>Asks the crawlers from external search engines not to index
		unwanted pages by using the meta tag. Check the viewes you want the
		search engines to index.</p>
	_HTML
@search_control_categorirs = [
	[ 'Latest', 'latest' ], [ 'One-day', 'day' ], [ 'One-month', 'month' ],
	[ 'Same-day', 'nyear' ], [ 'Category', 'category' ]
]
