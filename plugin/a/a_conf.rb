#!/usr/bin/env ruby
# a_conf.rb
#
# アンカー自動生成プラグイン辞書ファイル編集CGI tDiary-1.5.x Version
#
# アンカー自動生成プラグインの辞書ファイルをWWWから編集できるようにします。
# tDiaryのindex.rb/update.rbが置いてあるディレクトリに置きindex.rbと同じ
# アクセス権を与えてWWWブラウザから呼び出します。
# なお、他の人に編集されてしまうのはマズイのでupdate.rb同様に.htaccessで
# アクセス制限をかけてください。
#
# 詳しくはこちら：http://home2.highway.ne.jp/mutoh/tools/ruby/ja/a.html
#
# Copyright (c) 2002,2003 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
# 

$KCODE= 'e'
BEGIN { $defout.binmode }

begin
  if FileTest::symlink?( __FILE__ ) then
	org_path = File::dirname( File::readlink( __FILE__ ) )
  else
	org_path = File::dirname( __FILE__ )
  end
  $:.unshift org_path
  require 'tdiary'
  
  module TDiaryAnchorModule
	def filepath
	  if @options and @options["a.path"]
		return @options["a.path"]
	  else
		return cache_path + "/a.dat"
	  end
	end

	def readfile
	  path = filepath
	  if FileTest.exist?( path )
		open( path, "r" ) do |i|
		  @anchor_plugin_data = i.readlines
		end
	  else
		@anchor_plugin_data = ""
	  end
	end
  end
	
  class TDiaryAnchor < TDiary::TDiaryBase
	include TDiaryAnchorModule
	def initialize( cgi, rhtml, conf )
	  super
	  readfile
	end
  end

  class TDiaryAnchorSaveConf < TDiary::TDiaryBase
	include TDiaryAnchorModule
	def initialize( cgi, rhtml, conf )
	  super
	  path = filepath

	  if FileTest.exist?(path)
		open( path, "r" ) do |i|
		  open( path + "~", "w" ) do |o|
			o.print i.readlines
		  end
		end
	  end

	  open( path, 'w' ) do |o|
		@cgi["anchor_plugin_data"].each do |v|
			v.split(/\n/).each do |line|
		     o.print line, "\n" if line =~ /\w/
		   end
		end
	  end
	  readfile
	end
  end

  @cgi = CGI::new
  tdiary = nil
  
  begin
	if @cgi.valid?( 'anchor' )
	  tdiary = TDiaryAnchor::new( @cgi, 'a_conf.rhtml', TDiary::Config::new )
	elsif @cgi.valid?( 'save_anchor' )
	  tdiary = TDiaryAnchorSaveConf::new( @cgi, 'a_conf.rhtml', TDiary::Config::new )
	end
  rescue TDiary::TDiaryError
  end
  tdiary = TDiaryAnchor::new( @cgi, 'a_conf.rhtml', TDiary::Config::new ) unless tdiary
  
  head = body = ''
  if @cgi.mobile_agent? then
	body = tdiary.eval_rhtml( 'i.' ).to_sjis
	head = @cgi.header(
					   'type' => 'text/html',
					   'charset' => 'Shift_JIS',
					   'Content-Length' => body.size.to_s,
					   'Vary' => 'User-Agent'
					   )
  else
	body = tdiary.eval_rhtml
	head = @cgi.header(
					   'type' => 'text/html',
					   'charset' => 'EUC-JP',
					   'Content-Length' => body.size.to_s,
					   'Vary' => 'User-Agent'
					   )
  end
  print head
  print body if /HEAD/i !~ @cgi.request_method
rescue Exception
  puts "Content-Type: text/plain\n\n"
  puts "#$! (#{$!.class})"
  puts ""
  puts $@.join( "\n" )
end

