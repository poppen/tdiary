=begin
= Meta-scheme plugin((-$Id: referer_scheme.rb,v 1.1 2003-12-16 17:26:58 zunda Exp $-))
Enables to prefix `meta' schemes to URL regexp of the refer_table. See
#{lang}/referer_scheme.rb for a documentation.

== Copyright
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

class << @conf.referer_table

	# expands referer_table according to the meta-scheme
	alias referer_scheme_each_orig each
	def each( &block )
		self.referer_scheme_each_orig do |url, name|
			/^(\w+):/ =~ url
			if $1 && self.respond_to?( "scheme_#{$1}", true ) then
				self.send( "scheme_#{$1}", $', name, block )
			else
				block.call( url, name )
			end
		end
	end

end
