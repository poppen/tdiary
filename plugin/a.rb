# a.rb
# -pv-
#
# 名称：
# アンカー自動生成プラグイン
#
# 概要：
# 引数に基づきアンカーを自動生成します。
# または、辞書ファイルに基づきアンカーを自動生成します(tDiary-1.4.1以降)。
#
# 使う場所：
# 本文、ヘッダ、もしくはフッタ
#
# 使い方：
# 1. a(key, option_or_name = "", name = nil)
#	  key - アンカーのキー名称(キーが一致しない場合はそれ自身がURLになる)
#	  option_or_name - 一時的に追加する任意の文字列（省略可能）
#									 キーが一致しない場合は表示文字列になる
#    name - 表示文字列。辞書ファイルとは違う名前を付けたいときに使う（省略可能）
#
# a "home"
# a "home", "20020329.html", "こちら"
# a "http://www.hoge.com/diary/", "Hoge Diary"
#
# 2. a("name|key:option")
#    こちらは1.を1つの文字列にまとめた感じです。入力数が減るので慣れると
#    使いやすいです。keyとoptionの間は':'を、nameとkeyの間は'|'で区切り
#    ます。nameとoptionは省略可能です。
#    また、keyにはキーワードかURLを入れます。YYYYMM...という形式を入れると
#    myとほぼ同じ動作をします(titleは表示できません)。
#    (注意) 1.の方法とnameの位置が異なるので混乱しないようにしてください。
#
# a "key"
# a "key:20020329.html"
# a "key:20020329.html|こちら"
# a "Hoge Diary|http://www.hoge.com/diary/"
# a "Hoge Diary|20020201.html#p01"  #=> myと同じです(引数は逆だけど)。
#
# その他のオプション:
# @options['a.tlink'] = true
#  trueに指定すると、title属性値としてリンク先の情報を表示します。
#  ただし、このオプションを有効にした場合、毎回、リンク先へのアクセスが
#  発生します。レンタルサーバ等で使用して負荷が高くなってしまった
#  場合はfalseにしてください。指定しない場合はfalseです。
#
# @options['a.path'] = "/home/hoge/"
#  辞書ファイルを使う場合は、辞書ファイルのpathを指定します。
#  指定しない場合は、@data_path/cache/a.datになります。
#
# 辞書ファイル編集用CGI呼び出しボタン:
# 辞書ファイル編集用CGI呼び出しボタンを指定します。ヘッダ、もしくはフッタに置いて
# ください。
#
# navi_a(name = "a.rb設定") - 辞書ファイル編集CGIを呼び出します。
#	name - ボタン名称（省略した場合は、"a.rb設定"になる）
#
# その他：
# その他の情報は http://home2.highway.ne.jp/mutoh/tools/ruby/ja/a.html 
# を参照してください。
# 
# Copyright (c) 2002,2003 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
# 
=begin ChangeLog
2003-03-03 MUTOH Masao <mutoh@highway.ne.jp>
	* "name|key:option"形式対応
	* my形式対応
	* 引数,a.dat辞書にcharset導入。optionに日本語指定が可能になった(defaultはeuc)
	* version 1.3.0

2002-05-19 MUTOH Masao <mutoh@highway.ne.jp>
	* ドキュメントアップデート

2002-05-08 MUTOH Masao <mutoh@highway.ne.jp>
	* URLのみ指定で何も表示されない不具合の修正
	* version 1.2.1

2002-05-05 MUTOH Masao <mutoh@highway.ne.jp>
	* @options["a.tlink"]追加。trueを指定するとtlinkを使ってtitleを取得
	  するようになる。
	* ドキュメントアップデート
	* version 1.2.0

2002-05-01 MUTOH Masao <mutoh@highway.ne.jp>
	* コードのクリーンアップ。インスタンス変数にはプリフィクス
		a_をつけるようにした。
	* 辞書ファイルを標準で@data_path/cache/a.datにした
	* 辞書ファイル設定用のCGIであるa_conf.rbを追加した
	* メソッドnavi_aを追加した
	* version 1.1.0

2002-03-29 MUTOH Masao <mutoh@highway.ne.jp>
	* version 1.0.0
=end

require 'nkf'

A_REG_PIPE = /\|/
A_REG_COLON = /\:/
A_REG_URL = /:\/\//
A_REG_CHARSET = /euc|sjis|jis/
A_REG_CHARSET2 = /sjis|jis/
A_REG_MY = /^\d{8}/

if @options and @options["a.path"] 
	a_path = @options["a.path"]
else
	a_path = @cache_path + "/a.dat"
end

@a_anchors = Hash.new
if FileTest::exist?(a_path)
	open(a_path) do |file|
		file.each_line do |line|
			key, baseurl, *data = line.split(/\s+/)
			if data.last =~ A_REG_CHARSET
				charset = data.pop
			else
				charset = ""
			end
			@a_anchors[key] = [baseurl, data.join(" "), charset]
		end
	end
end

def a_separate(word)
	if A_REG_PIPE =~ word
		name, data = $`, $'
	else
		name, data = nil, word
	end

	option = nil
	if data =~ A_REG_URL
		key = data
	elsif data =~ A_REG_COLON
		key, option = $`, $'
	else
		key = data #Error pattern
	end
	[key, option, name]
end

def a_convert_charset(option, charset)
	return "" unless option
	return option unless charset
	if charset =~ A_REG_CHARSET2
		ret = CGI.escape(NKF::nkf("-#{charset[0].chr}", option))
	else
		ret = CGI.escape(option)
	end
	ret
end

def a_anchor(key)
	data = @a_anchors[key]
	if data
		data.collect{|v| v ? v.dup : nil}
	else
		[nil, nil, nil]
	end
end

def a(key, option_or_name = nil, name = nil, charset = nil)
	url, value, cset = a_anchor(key)
	if url.nil?
		key, option, name = a_separate(key)
		url, value, cset = a_anchor(key)
		option_or_name = option unless option_or_name;
	end
	charset = cset unless charset
	
	value = key if value == ""

	if url.nil?
		url = key
		if name
			value = name
			url += a_convert_charset(option_or_name, charset)
		elsif option_or_name
			value = option_or_name 
		else
			value = key
		end
	else
		url += a_convert_charset(option_or_name, charset)
		value = name if name
	end

   if key =~ A_REG_MY
      option_or_name = key unless option_or_name
      return my(option_or_name, name)
   end

	if @options["a.tlink"] 
		if defined?(tlink)
			url.untaint
			result = tlink(url, value)
		else
			result = "tlink is not available."
		end
	else
		result = %Q[<a href="#{url}">#{value}</a>]
	end
	result
end

def navi_a(name = "a.rb設定")
	"<span class=\"adminmenu\"><a href=\"a_conf.rb\">#{name}</a></span>\n"
end

