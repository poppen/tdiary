# image.rb $Revision: 1.13 $
# -pv-
# 
# 名称:
# 絵日記Plugin
#
# 概要:
# 日記更新画面からの画像アップロード、本文への表示
#
# 使う場所:
# 本文
#
# 使い方:
# image( number, 'altword', thumbnail ) - 画像を表示します。
#    number - 画像の番号0、1、2等
#    altword - imgタグの altに入れる文字列
#    thumbnail - サムネイル(小さな画像)を指定する(省略可)
#
# image_left( number, 'altword', thumbnail ) - imageにclass=leftを追加します。
# image_right( number, 'altword', thumbnail ) - imageにclass=rightを追加します。
#
# image_link( number, 'desc' ) - 画像へのリンクを生成します。
#    number - 画像の番号0、1、2等
#    desc - 画像の説明
#
# その他:
# tDiary version 1.5.4以降で動作します。
# tdiary.confで指定できるオプション:
#  @options['image.dir']
#     画像ファイルを保存するディレクトリ。無指定時は'./images/'
#     Webサーバの権限で書き込めるようにしておく必要があります。
#  @options['image.url']
#     画像ファイルを保存するディレクトリのURL。無指定時は'./images/'
#  @options['image.maxnum']
#     1日あたりの最大画像数。無指定時は1
#     ただし@secure = true時のみ有効
#  @options['image.maxsize']
#     1枚あたりの最大画像バイト数。無指定時は10000
#     ただし@secure = true時のみ有効
#
# ライセンスについて:
# Copyright (c) 2002,2003 Daisuke Kato <dai@kato-agri.com>
# Copyright (c) 2002 Toshi Okada <toshi@neverland.to>
# Copyright (c) 2003 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
# Distributed under the GPL
#

=begin Changelog
2003-09-25 TADA Tadashi <sho@spc.gr.jp>
	* english support.

2003-05-17 TADA Tadashi <sho@spc.gr.jp>
	* add thumbnail in 3rd parameter of image method.
	* force image width to 160 in update form.
	* add image_link method.

2003-04-25 TADA Tadashi <sho@spc.gr.jp>
	* maxnum and maxsize effective in secure mode.
	* show message when upload failed.

2003-04-23 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* add JavaScript for insert plugin tag into diary.

2003-04-24 TADA Tadashi <sho@spc.gr.jp>
	* enable running on secure mode.

2003-04-23 Daisuke Kato <dai@kato-agri.com>
	* tuning around form tag.

2003-04-23 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* Now img tag includes class="photo".
	* New Option. image.maxnum, image.maxsize.
	* fine tuning around form tag.

2003-04-22 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
	* version 0.5 first form_proc version.
=end

unless @resource_loaded then
	def image_error_num( max ); "画像は1日#{max}枚までです。不要な画像を削除してから追加してください"; end
	def image_error_size( max ); "画像の最大サイズは#{max}バイトまでです"; end
	def image_label_list_caption; '絵日記(一覧・削除)'; end
	def image_label_add_caption; '絵日記(追加)'; end
	def image_label_description; '画像の説明'; end
	def image_label_add_plugin; '本文に追加'; end
	def image_label_delete; 'チェックした画像の削除'; end
	def image_label_only_jpeg; 'JPEGのみ'; end
	def image_label_add_image; '画像の追加'; end
end

def image( id, alt = 'image', thumbnail = nil, width = nil, place = 'photo' )
	if @conf.secure then
		image = "#{@image_date}_#{id}.jpg"
		image_t = "#{@image_date}_#{thumbnail}.jpg" unless thumbnail
	else
   	image = image_list( @image_date )[id.to_i]
   	image_t = image_list( @image_date )[thumbnail.to_i]
	end
	if thumbnail then
   	%Q[<a href="#{@image_url}/#{image}"><img class="#{place}" src="#{@image_url}/#{image_t}" alt="#{alt}"></a>]
	else
   	%Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}">]
	end
end

def image_left( id, alt = "image", thumbnail = nil, width = nil )
   image( id, alt, thumbnail, width, "left" )
end

def image_right( id, alt = "image", thumbnail = nil, width = nil )
   image( id, alt, thumbnail, width, "right" )
end

def image_link( id, desc )
	if @conf.secure then
		image = "#{@image_date}_#{id}.jpg"
	else
   	image = image_list( @image_date )[id.to_i]
	end
   %Q[<a href="#{@image_url}/#{image}">#{desc}</a>]
end

#
# initialize
#
@image_dir = @options && @options['image.dir'] || './images/'
@image_dir.chop! if /\/$/ =~ @image_dir
@image_url = @options && @options['image.url'] || './images/'
@image_url.chop! if /\/$/ =~ @image_url

add_body_enter_proc do |date|	
   @image_date = date.strftime( "%Y%m%d" )
   ""
end

#
# service methods below.
#

def image_ext
	if @conf.secure then
		'jpg'
	else
		'jpg|jpeg|gif|png'
	end
end

def image_list( date )
	return @image_list if @conf.secure and @image_list
	list = []
	reg = /#{date}_(\d+)\.(#{image_ext})$/
	Dir::foreach( @image_dir ) do |file|
		list[$1.to_i] = file if reg =~ file
	end
	list
end

if @conf.secure and /^(form|edit|formplugin|showcomment)$/ =~ @mode then
	@image_list = image_list( @date.strftime( '%Y%m%d' ) )
end

if /^formplugin$/ =~ @mode then
   maxnum = @options['image.maxnum'] || 1
   maxsize = @options['image.maxsize'] || 10000

	begin
	   date = @date.strftime( "%Y%m%d" )
		images = image_list( date )
	   if @cgi.params['plugin_image_addimage'][0]
	      filename = @cgi.params['plugin_image_file'][0].original_filename
	      if filename =~ /\.(#{image_ext})\z/i
	         extension = $1.downcase
				begin
	         	size = @cgi.params['plugin_image_file'][0].size
				rescue NameError
	         	size = @cgi.params['plugin_image_file'][0].stat.size
				end
				if @conf.secure then
					raise image_error_num( maxnum ) if images.compact.length >= maxnum
					raise image_error_size( maxsize ) if size > maxsize
				end
	         file = "#{@image_dir}/#{date}_#{images.length}.#{extension}".untaint
		      File::umask( 022 )
		      File::open( file, "wb" ) do |f|
		         f.puts @cgi.params['plugin_image_file'][0].read
		      end
	         images << File::basename( file ) # for secure mode
	      end
	   elsif @cgi.params['plugin_image_delimage'][0]
	      @cgi.params['plugin_image_id'].each do |id|
	         file = "#{@image_dir}/#{images[id.to_i]}".untaint
	         if File::file?( file ) && File::exist?( file )
	            File::delete( file )
	         end
	         images[id.to_i] = nil # for secure mode
	      end
	   end
	rescue
		@image_message = $!.to_s
	end
end

add_form_proc do |date|
	r = ''
	tabidx = 1200
	images = image_list( date.strftime( '%Y%m%d' ) )
	if images.length > 0 then
		r << %Q[
		<script type="text/javascript">
		<!--
		var elem=null
		function ins(val){
			elem.value+=val
		}
		window.onload=function(){
			for(var i=0;i<document.forms.length;i++){
				for(var j=0;j<document.forms[i].elements.length;j++){
					var e=document.forms[i].elements[j]
					if(e.type&&e.type=="textarea"){
						if(elem==null){
							elem=e
						}
						e.onfocus=new Function("elem=this")
					}
				}
			}
		}
		//-->
		</script>
		]
		if @conf.style == "Wiki"
			ptag1 = "{{"
			ptag2 = "}}"
		elsif @conf.style == "RD"
			ptag1 = "((%"
			ptag2 = "%))"
		else
			ptag1 = "&lt;%="
			ptag2 = "%&gt;"
		end
	   r << %Q[<div class="form">
		<div class="caption">
		#{image_label_list_caption}
		</div>
		<form class="update" method="post" action="#{@conf.update}"><div>
		<table>
		<tr>]
	   images.each_with_index do |img,id|
	      r << %Q[<td><img class="form" src="#{@image_url}/#{img}" alt="#{id}" width="160"></td>] if img
	   end
		r << "</tr><tr>"
	   images.each_with_index do |img,id|
			next unless img
			ptag = "#{ptag1}image #{id}, '#{image_label_description}'#{ptag2}"
	      r << %Q[<td>
			<input type="checkbox" tabindex="#{tabidx+id*2}" name="plugin_image_id" value="#{id}">#{id}
			<input type="button" tabindex="#{tabidx+id*2+1}" onclick="ins(&quot;#{ptag}&quot;)" value="#{image_label_add_plugin}">
			</td>]
	   end
	   r << %Q[</tr>
		</table>
		<input type="hidden" name="plugin_image_delimage" value="true">
	   <input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}">
	   <input type="submit" tabindex="#{tabidx+97}" name="plugin" value="#{image_label_delete}">
	   </div></form>
		</div>]
	end

   r << %Q[<div class="form">
	<div class="caption">
	#{image_label_add_caption}
	</div>]
	if @image_message then
		r << %Q[<p class="message">#{@image_message}</p>]
	end
   r << %Q[<form class="update" method="post" enctype="multipart/form-data" action="#{@conf.update}"><div>
	#{@conf.secure ? image_label_only_jpeg : ''}
   <input type="hidden" name="plugin_image_addimage" value="true">
   <input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}">
   <input type="file" tabindex="#{tabidx+98}" name="plugin_image_file">
   <input type="submit" tabindex="#{tabidx+99}" name="plugin" value="#{image_label_add_image}">
   </div></form>
	</div>]
end

