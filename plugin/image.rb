# image.rb $Revision: 1.2 $
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
# image( number, 'altword' ) - 画像を表示します。
#  number - 画像の番号0、1、2等
#  altword - imgタグの altに入れる文字列
#
# image_left( number, 'altword' ) - imageにclass=leftを追加します。
# image_right( number, 'altword' ) - imageにclass=rightを追加します。
#
# その他:
# tDiary version 1.5.3.20030420以降で動作します。
# tdiary.confで指定できるオプション:
#  @optons['image.dir']
#     画像ファイルを保存するディレクトリ。無指定時は'./images/'
#     Webサーバの権限で書き込めるようにしておく必要があります。
#  @options['image.url']
#     画像ファイルを保存するディレクトリのURL。無指定時は'./images/'
#  @options['image.maxnum']
#     1日あたりの最大画像数。無指定時は10
#  @options['image.maxsize']
#     1枚あたりの最大画像バイト数。無指定時は512000
#
# @secure = trueな環境で動かす場合は、必ずmaxnumとmaxsizeを適切な
# 値に制限することを推奨します。
#
# ライセンスについて:
# Copyright (c) 2002,2003 Daisuke Kato <dai@kato-agri.com>
# Copyright (c) 2002 Toshi Okada <toshi@neverland.to>
# Copyright (c) 2003 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
# Distributed under the GPL

=begin Changelog
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

def image( id, alt = 'image', width = nil, place = 'photo' )
	if @conf.secure then
		image = "#{@image_date}_#{id}.jpg"
	else
   	image = image_list( @image_date )[id.to_i]
	end
   %Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}">]
end

def image_left( id, alt = "image", width = nil )
   image( id, alt, width, "left" )
end

def image_right( id, alt = "image", width = nil )
   image( id, alt, width, "right" )
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
	reg = /#{date}_(\d+)\.#{image_ext}$/
	Dir::foreach( @image_dir ) do |file|
		list[$1.to_i] = file if reg =~ file
	end
	list
end

if @conf.secure and /^(form|edit|formplugin)$/ =~ @mode then
	@image_list = image_list( @date.strftime( '%Y%m%d' ) )
end

if /^formplugin$/ =~ @mode then
   maxnum = @options['image.maxnum'] || 10
   maxsize = @options['image.maxsize'] || 512000

   date = @date.strftime( "%Y%m%d" )
	images = image_list( date )
   if @cgi.params['plugin_image_addimage'][0]
      filename = @cgi.params['plugin_image_file'][0].original_filename
      if filename =~ /\.(#{image_ext})\z/i
         extension = $1
			begin
         	size = @cgi.params['plugin_image_file'][0].size
			rescue NameError
         	size = @cgi.params['plugin_image_file'][0].stat.size
			end
         if images.length < maxnum and size <= maxsize then
            file = "#{@image_dir}/#{date}_#{images.length}.#{extension}".untaint
	         File::umask( 022 )
	         File::open( file, "wb" ) do |f|
	            f.puts @cgi.params['plugin_image_file'][0].read
	         end
            images << File::basename( file ) # for secure mode
         end
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
end

add_form_proc do |date|
	r = ''
	images = image_list( date.strftime( '%Y%m%d' ) )
	if images.length > 0 then
	   r << %Q[<div class="form">
		<div class="caption">
		絵日記(一覧・削除)
		</div>
		<form class="update" method="post" action="#{@conf.update}"><div>
		<table>
		<tr>]
	   images.each_with_index do |img,id|
	      r << %Q[<td><img class="form" src="#{@image_url}/#{img}"></td>] if img
	   end
		r << "</tr><tr>"
	   images.each_with_index do |img,id|
	      r << %Q[<td><input type="checkbox" name="plugin_image_id" value="#{id}">#{id}</td>] if img
	   end
	   r << %Q[</tr>
		</table>
		<input type="hidden" name="plugin_image_delimage" value="true">
	   <input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}">
	   <input type="submit" name="plugin" value="選択した画像ファイルの削除">
	   </div></form>
		</div>]
	end

   r << %Q[<div class="form">
	<div class="caption">
	絵日記(追加)
	</div>
   <form class="update" method="post" enctype="multipart/form-data" action="#{@conf.update}"><div>
   <input type="hidden" name="plugin_image_addimage" value="true">
   <input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}">
   <input type="file"	name="plugin_image_file">
   <input type="submit" name="plugin" value="画像ファイルの追加">
   </div></form>
	</div>]
end

