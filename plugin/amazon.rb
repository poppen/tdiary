# amazon.rb $Revision: 1.23 $
#
# See document in language resource file: en/amazon.rb
#
# ドキュメントはja/amazon.rbを見てください。
#
# Copyright (C) 2002 by HAL99 <hal99@mtj.biglobe.ne.jp>
#
# Original: HAL99 <hal99@mtj.biglobe.ne.jp>
# Modified: by TADA Tadashi<sho@spc.gr.jp>,
#              kazuhiko<kazuhiko@fdiary.net>,
#              woods<sodium@da2.so-net.ne.jp>,
#              munemasa<munemasa@t3.rim.or.jp>,
#              dai<dai@kato-agri.com>
#
require 'net/http'
require 'timeout'


def getAmazon( asin )

	cache = "#{@cache_path}/amazon"

	Dir::mkdir( cache ) unless File::directory?( cache )
	begin
		item = File::readlines( "#{cache}/#{asin}" )
		raise if item.length < 2

		return item
	rescue
	end

	limittime = 10

	proxy_host = nil
	proxy_port = 8080
	if /^([^:]+):(\d+)$/ =~ @conf['amazon.proxy'] then
		proxy_host = $1
		proxy_port = $2.to_i
	end

	item_url = nil
	item_name = nil
	img_url = nil
	img_name = nil
	img_height = nil
	img_width = nil

	timeout( limittime ) do
		item_url = "#{@amazon_url}/#{asin}/"

		begin
			if %r|http://([^:/]*):?(\d*)(/.*)| =~ item_url then
				host = $1
				port = $2.to_i
				path = $3
				raise 'not amazon domain' if host !~ /\.amazon\.(com|co\.uk|co\.jp|de|fr|ca)$/
				raise 'bad location was returned.' unless host and path
				port = 80 if port == 0
			end
			Net::HTTP.version_1_1
			Net::HTTP.Proxy( proxy_host.untaint, proxy_port.untaint ).start( host.untaint, port.untaint ) do |http|
				response, = http.get( path )
				response.body.each do |line|
					line = @conf.to_native( line )
					if line =~ @amazon_item_name
						item_name = CGI::escapeHTML(CGI::unescapeHTML($1))
					end
					if line =~ @amazon_item_image
						img_tag = $1
						img_url = $2
						img_name = $3
						if img_tag =~ / width="?(\d+)"?/i
							img_width = $1
						end
						if img_tag =~ / height="?(\d+)"?/i
							img_height = $1
						end
					end
				end
			end
		rescue Net::ProtoRetriableError => err
			$stderr.puts "1 #$!"
			item_url = err.response['location']
			retry
		rescue
			$stderr.puts "2 #$!: #{item_url}"
			raise 'getting item was failed'
		end
	end
	item = [item_url.strip,item_name,img_url,img_name,img_width,img_height]
	open("#{cache}/#{asin}","w") do |f|
		item.each do |i|
			next unless i
			f.print i,"\n"
			end
	end
	return item
end

def amazonNoImg(item_url,item_name)
	%Q[<a href="#{item_url.strip}/ref=nosim/">#{item_name.strip}</a>]
end


def getAmazonImg(position,asin,comment)
	return isbn( asin, comment || asin )  if @conf.secure

	begin

		item = getAmazon(asin)
		item[0].sub!( %r|[^/]+$|, @conf['amazon.aid'] ) if @conf['amazon.aid']

		item_name = item[1]
		item[1] = comment if comment
		unless item[2] then
			if @conf['amazon.nodefault']
				return amazonNoImg(item[0],item[1])
			else
				item[2] = "http://images-jp.amazon.com/images/G/09/icons/books/comingsoon_books.gif"
			end
		end
		if @conf['amazon.imgsize'] == 1 then
			item[2].gsub!(/MZZZZZZZ/, 'TZZZZZZZ')
		end
		if @conf['amazon.imgsize'] == 2 then
			item[2].gsub!(/MZZZZZZZ/, 'THUMBZZZ')
		end
		r = ""
		r << %Q[<a href="#{item[0].strip}/ref=nosim/">]
		r << %Q[<img class="#{position}" src="#{item[2].strip}" ]
		if @conf['amazon.imgsize'] == 0 then
			r << %Q[width="#{item[4].strip}" ] if item[4]
			r << %Q[height="#{item[5].strip}" ] if item[5]
		end
		r << %Q[alt="#{item[1].strip}">]
		if !@conf['amazon.hidename']
			r << item[1].strip if position == "amazon"
		end
		r << %Q[</a>]
	rescue
		$stderr.puts "3 #$!"
		asin
	end
end

def isbnImgLeft(asin,comment = nil)
	getAmazonImg("left",asin,comment)
end
alias isbn_image_left isbnImgLeft

def isbnImgRight(asin,comment = nil)
	getAmazonImg("right",asin,comment)
end
alias isbn_image_right isbnImgRight

def isbnImg(asin,comment = nil)
	getAmazonImg("amazon",asin,comment)
end
alias isbn_image isbnImg
alias amazon isbnImg

def isbn( asin, comment )
	item_url = "http://www.amazon.co.jp/exec/obidos/ASIN/#{asin}/"
	item_url << @conf['amazon.aid'] if @conf['amazon.aid']
	amazonNoImg( item_url, comment )
end

unless @conf.secure and @conf['amazon.hideconf'] then
	add_conf_proc( 'amazon', @amazon_label_conf ) do
		amazon_conf_proc
	end
end
def amazon_conf_proc
	if @mode == 'saveconf' then
		unless @conf.secure then
			@conf['amazon.imgsize'] = @cgi.params['amazon.imgsize'][0].to_i
			@conf['amazon.hidename'] = (@cgi.params['amazon.hidename'][0] == 'true')
			@conf['amazon.nodefault'] = (@cgi.params['amazon.nodefault'][0] == 'true')
		end
		if not @conf['amazon.hideconf'] then
			@conf['amazon.aid'] = @cgi.params['amazon.aid'][0]
		end
	end

	result = ''
	unless @conf.secure then
		result << <<-HTML
	<h3>#{@amazon_label_imgsize}</h3>
	<p><select name="amazon.imgsize">
		<option value="0"#{if @conf['amazon.imgsize'] == 0 then " selected" end}>#{@amazon_label_large}</option>
		<option value="1"#{if @conf['amazon.imgsize'] == 1 then " selected" end}>#{@amazon_label_regular}</option>
		<option value="2"#{if @conf['amazon.imgsize'] == 2 then " selected" end}>#{@amazon_label_small}</option>
	</select></p>
	<h3>#{@amazon_label_title}</h3>
	<p><select name="amazon.hidename">
		<option value="true"#{if @conf['amazon.hidename'] then " selected" end}>#{@amazon_label_hide}</option>
		<option value="false"#{if not @conf['amazon.hidename'] then " selected" end}>#{@amazon_label_show}</option>
	</select></p>
	<h3>#{@amazon_label_notfound}</h3>
	<p><select name="amazon.nodefault">
		<option value="true"#{if @conf['amazon.nodefault'] then " selected" end}>#{@amazon_label_usetitle}</option>
		<option value="false"#{if not @conf['amazon.nodefault'] then " selected" end}>#{@amazon_label_usedefault}</option>
	</select></p>
	HTML
	end
	if not @conf['amazon.hideconf'] then
		result << <<-HTML
	<h3>#{@amazon_label_aid}</h3>
	<p><input name="amazon.aid" value="#{CGI::escapeHTML( @conf['amazon.aid'] ) if @conf['amazon.aid']}"></p>
	HTML
	end
	result
end
