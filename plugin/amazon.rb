# amazon.rb $Revision: 1.50 $: Making link with image to Amazon using Amazon ECS.
#
# see document: #{@lang}/amazon.rb
#
# Copyright (C) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
require 'open-uri'
require 'timeout'
require 'rexml/document'
require 'nkf'

# do not change these variables
@amazon_subscription_id = '1CVA98NEF1G753PFESR2'
@amazon_require_version = '2005-07-26'

def amazon_call_ecs( asin )
	aid =  @conf['amazon.aid'] || ''
	aid = 'cshs-22' if aid.length == 0

	url =  @amazon_ecs_url.dup
	url << "?Service=AWSECommerceService"
	url << "&SubscriptionId=#{@amazon_subscription_id}"
	url << "&AssociateTag=#{aid}"
	url << "&Operation=ItemLookup"
	url << "&ItemId=#{asin}"
	url << "&ResponseGroup=Medium"
	url << "&Version=#{@amazon_require_version}"

	proxy = nil
	if @conf['amazon.proxy'] and @conf['amazon.proxy'].length > 0 then
		proxy = @conf['amazon.proxy']
		proxy = 'http://' + proxy unless proxy =~ /^https?:/
	end

	timeout( 10 ) do
		open( url, :proxy => proxy ) {|f| f.read}
	end
end

def amazon_to_html( item, with_image = true, label = nil, pos = 'amazon' )
	with_image = false if @mode == 'categoryview'
	begin
		author = ''
		item.elements.each( '*/Author' ) do |a|
			author << a.text << '/'
		end
		author = "(#{NKF::nkf '-We', author.chop!})"
	rescue
		author = ''
	end

	unless label then
		label = %Q|#{NKF::nkf '-We', item.elements.to_a( '*/Title' )[0].text}#{author}|
	end

	image = ''
	if with_image then
		begin
			size = case @conf['amazon.imgsize']
			when 0; 'Large' 
			when 2; 'Small'
			else;   'Medium'
			end
			image = <<-HTML
			<img class="#{h pos}"
			src="#{h item.elements.to_a( "#{size}Image/URL" )[0].text}"
			height="#{h item.elements.to_a( "#{size}Image/Height" )[0].text}"
			width="#{h item.elements.to_a( "#{size}Image/Width" )[0].text}"
			alt="#{h label}" title="#{h label}">
			HTML
		rescue
			if @conf['amazon.nodefault'] then
				image = h( label )
			else
				base = @conf['amazon.default_image_base'] || 'http://www.tdiary.org/images/amazondefaults/'
				name = case @conf['amazon.imgsize']
				when 0; 'large'
				when 2; 'small'
				else;   'medium'
				end
				size = case @conf['amazon.imgsize']
				when 0; [500, 380]
				when 2; [75, 57]
				else;   [160, 122]
				end
				image = <<-HTML
				<img class="#{h pos}"
				src="#{h base}#{name}.png"
				height="#{size[0]}"
				width="#{size[1]}"
				alt="#{h label}" title="#{h label}">
				HTML
			end
		end
		image.gsub!( /\t/, '' )
	end

	if with_image and @conf['amazon.hidename'] || pos != 'amazon' then
		label = ''
	end

	%Q|<a href="#{h item.elements.to_a( 'DetailPageURL' )[0].text}">#{image}#{h label}</a>|
end

def amazon_secure_html( asin, with_image, label, pos = 'amazon' )
	with_image = false if @mode == 'categoryview'
	label = asin unless label

	image = ''
	if with_image and @conf['amazon.secure-cgi'] then
		image = <<-HTML
		<img class="#{h pos}"
		src="#{h @conf['amazon.secure-cgi']}?asin=#{h(u(asin))};size=#{h(u(@conf['amazon.imgsize']))}"
		alt="#{h label}" title="#{h label}">
		HTML
	end
	image.gsub!( /\t/, '' )

	if with_image and @conf['amazon.hidename'] || pos != 'amazon' then
		label = ''
	end

	url =  "#{@amazon_url}/#{u asin}"
	url << "/#{u @conf['amazon.aid']}" if @conf['amazon.aid'] and @conf['amazon.aid'].length > 0
	url << "/ref=nosim/"
	%Q|<a href="#{h url}">#{image}#{h label}</a>|
end

def isbn_10?( isbn )
	isbn.gsub( /[^\dX]/, '' ).length == 10
end

def isbn_13?( isbn )
	isbn.gsub( /[^\d]/, '' ).length == 13
end

def isbn_check_digit_10( isbn )
	raise ArgumentError::new( "#{isbn} is wrong ISBN-10" ) unless isbn_10?( isbn )

	sum = 0
	isbn.gsub( /[^\dX]/, '' ).chop.split( // ).each_with_index do |item, index|
		sum += item.to_i * (10 - index)
	end
	check_digit = 11 - sum % 11
	check_digit = case check_digit
	when 10; 'X'
	when 11; '0'
	else; check_digit.to_s
	end
	check_digit
end

def isbn_13to10( isbn13 )
	isbn10 = isbn13.gsub( /[^\d]/, '' )[3,10]
	check_digit = isbn_check_digit_10( isbn10 )
	isbn10[9] = check_digit
	isbn10
end

def amazon_get( asin, with_image = true, label = nil, pos = 'amazon' )
	if isbn_13?( asin ) # ISBN-13
		asin = isbn_13to10( asin )
	end

	asin = asin.to_s.strip # delete white spaces

	if @conf.secure then
		amazon_secure_html( asin, with_image, label, pos )
	else
		begin
			cache = "#{@cache_path}/amazon"
			Dir::mkdir( cache ) unless File::directory?( cache )
			begin
				xml = File::read( "#{cache}/#{asin}.xml" )
			rescue Errno::ENOENT
				xml =  amazon_call_ecs( asin )
				File::open( "#{cache}/#{asin}.xml", 'wb' ) {|f| f.write( xml )}
			end
			doc = REXML::Document::new( xml ).root
			item = doc.elements.to_a( '*/Item' )[0]
			amazon_to_html( item, with_image, label, pos )
		rescue Timeout::Error
			asin
		rescue NoMethodError
			if item == nil then
				message = doc.elements.to_a( 'Items/Request/Errors/Error/Message' )[0].text
				"#{label ? label : asin}<!--#{h NKF::nkf( '-We', message )}-->"
			else
				"#{label ? label : asin}<!--#{h $!}\n#{h $@.join( ' / ' )}-->"
			end
		end
	end
end

unless @conf.secure and not @conf['amazon.secure-cgi'] then
	add_conf_proc( 'amazon', @amazon_label_conf ) do
		amazon_conf_proc
	end
end

def amazon_conf_proc
	if @mode == 'saveconf' then
		unless @conf.secure and not @conf['amazon.secure-cgi'] then
			@conf['amazon.imgsize'] = @cgi.params['amazon.imgsize'][0].to_i
			@conf['amazon.hidename'] = (@cgi.params['amazon.hidename'][0] == 'true')
			unless @conf.secure then
				@conf['amazon.nodefault'] = (@cgi.params['amazon.nodefault'][0] == 'true')
				if @cgi.params['amazon.clearcache'][0] == 'true' then
					Dir["#{@cache_path}/amazon/*"].each do |cache|
						File::delete( cache.untaint )
					end
				end
			end
		end
		unless @conf['amazon.hideconf'] then
			@conf['amazon.aid'] = @cgi.params['amazon.aid'][0]
		end
	end

	result = ''
	unless @conf.secure and not @conf['amazon.secure-cgi'] then
		result << <<-HTML
			<h3>#{@amazon_label_imgsize}</h3>
			<p><select name="amazon.imgsize">
				<option value="0"#{" selected" if @conf['amazon.imgsize'] == 0}>#{@amazon_label_large}</option>
				<option value="1"#{" selected" if @conf['amazon.imgsize'] == 1}>#{@amazon_label_regular}</option>
				<option value="2"#{" selected" if @conf['amazon.imgsize'] == 2}>#{@amazon_label_small}</option>
			</select></p>
			<h3>#{@amazon_label_title}</h3>
			<p><select name="amazon.hidename">
				<option value="true"#{" selected" if @conf['amazon.hidename']}>#{@amazon_label_hide}</option>
				<option value="false"#{" selected" unless @conf['amazon.hidename']}>#{@amazon_label_show}</option>
			</select></p>
		HTML
		unless @conf.secure then
			result << <<-HTML
				<h3>#{@amazon_label_notfound}</h3>
				<p><select name="amazon.nodefault">
					<option value="true"#{" selected" if @conf['amazon.nodefault']}>#{@amazon_label_usetitle}</option>
					<option value="false"#{" selected" unless @conf['amazon.nodefault']}>#{@amazon_label_usedefault}</option>
				</select></p>
				<h3>#{@amazon_label_clearcache}</h3>
				<p><input type="checkbox" name="amazon.clearcache" value="true">#{@amazon_label_clearcache_desc}</input></p>
			HTML
		end
	end
	unless @conf['amazon.hideconf'] then
		result << <<-HTML
			<h3>#{@amazon_label_aid}</h3>
			<p>#{@amazon_label_aid_desc}</p>
			<p><input name="amazon.aid" value="#{h( @conf['amazon.aid'] ) if @conf['amazon.aid']}"></p>
		HTML
	end
	result
end
def isbn_image( asin, label = nil )
	amazon_get( asin, true, label )
end

def isbn_image_left( asin, label = nil )
	amazon_get( asin, true, label, 'left' )
end

def isbn_image_right( asin, label = nil )
	amazon_get( asin, true, label, 'right' )
end

def isbn( asin, label = nil )
	amazon_get( asin, false, label )
end

# for compatibility
alias isbnImgLeft isbn_image_left
alias isbnImgRight isbn_image_right
alias isbnImg isbn_image
alias amazon isbn_image
