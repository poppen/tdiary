# disp_referrer.rb $Revision: 1.3 $
# -pv-
#
# 名称：
# 本日のリンク元強化プラグイン
#
# 概要：
# 本日のリンク元でサーチエンジンの検索文字の文字化けを直します。
# また、サーチエンジンの検索結果を他のリンク元の下にまとめて表示します（デフォルト時）。
#
# 使い方：
# 文字化けを直すのみ（表示はtDiaryの標準時と同様の並びにする）の場合は、tdiary.confに
# 以下を追加してください。
# @options['disp_referrer.old'] = true
#
# 制限：
# EUC-JPで表現できない文字は表示できません。
#
# 著作権について：
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
=begin ChangeLog
2002-08-07  MUTOH Masao <mutoh@highway.ne.jp>
   * 表示対象のずれの修正
   * version 2.0.1

2002-08-06  MUTOH Masao <mutoh@highway.ne.jp>
   * google, Yahoo, Infoseek, Lycos, goo, OCN, excite, 
     msn, BIGLOBE, ODN, DIONからの内検索結果を、同アクセス数単位でリンク一覧の
     下側にまとめて表示するようにした。従来の表示結果にしたい場合は
     @options['disp_referrer.old'] = trueを設定する。
   * version 2.0.0

2002-07-24  MUTOH Masao <mutoh@highway.ne.jp>
   * alltheweb対応
   * jp.aol.com, aol.com対応
   * 文字列変換の順序を変更
   * version 1.1.0

2002-07-20  MUTOH Masao <mutoh@highway.ne.jp>
   * version 1.0.0
=end

require 'uconv'

eval(<<TOPLEVEL_CLASS, TOPLEVEL_BINDING)
def Uconv.unknown_unicode_handler(unicode)
   if unicode == 0xff5e
      "〜"
   else
      "?"
   end
end
class Diary
   def disp_referer( table, ref )
      ref = CGI::unescape( ref )
      if /((e|cs)=utf-?8|jp.aol.com)/i =~ ref
         begin
            ref = Uconv.u8toeuc(ref)
         rescue Uconv::Error
         end
      elsif /&#[0-9]+/ =~ ref
         ref.gsub!(/&#([0-9]+);/){|v|
            Uconv.u8toeuc([$1.to_i].pack("U"))
         }
      elsif NKF.guess(ref) == NKF::SJIS
         ref = ref.to_euc
      end
      str = nil
      table.each do |url, name|
         regexp = Regexp.new(url, Regexp::IGNORECASE)
         if regexp =~ ref then
            str = ref.gsub(regexp, name)
            break
         end
      end
      str ? str : ref
   end   
end
TOPLEVEL_CLASS

unless @options['disp_referrer.old'] #NEW VERSION

def referer_of_today_long( diary, limit )
  return '' if not diary or diary.count_referers == 0

  search_tables = [
    [["google検索","http://www.google.com/"],
	["^http://216.239.3...../search.*q=([^&]*).*", " \\1"],
    ["^http://www.google..*/.*q=([^&]*).*", " \\1"]],
    [["Yahoo内google検索","http://www.yahoo.co.jp/"],
	["^http://google.yahoo.*/.*?p=([^&]*).*", " \\1"]],
    [["Infoseek検索","http://www.infoseek.co.jp/"],
	["^http://www.infoseek.co.jp/.*?qt=([^&]*).*", " \\1"]],
    [["Lycos検索","http://www.lycos.co.jp/"],
	["^http://.*lycos.*/.*?query=([^&]*).*", " \\1"]],
    [["goo検索","http://www.goo.ne.jp/"],
	["^http://(www|search).goo.ne.jp/.*?MT=([^&]*).*", " \\2"]],
    [["@nifty検索", "http://www.nifty.com/"],
	["^http://(search|asearch|www).nifty.com/.*?(q|Text)=([^&]*).*", " \\3"]],
    [["OCN検索", "http://www.ocn.ne.jp/"],
	["^http://ocn.excite.co.jp/search.gw.*search=([^&]*).*", " \\1"]],
    [["excite検索", "http://www.excite.co.jp/"],
	["^http://.*excite.*/.*?(search|s)=([^&]*).*", " \\2"]],
    [["msn検索", "http://www.msn.co.jp/home.htm"],
	["^http://search.msn.co.jp/.*?(q|MT)=([^&]*).*", " \\2"]],
    [["BIGLOBE検索", "http://www.biglobe.ne.jp/"],
	["^http://cgi.search.biglobe.ne.jp/cgi-bin/search.*?q=([^&]*).*", " \\1"]],
    [["テレコムサーチ", "http://www.odn.ne.jp/"],
	["^http://search.odn.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", " \\2"]],
    [["DIONサーチ", "http://www.dion.ne.jp/"],
	["^http://dir.dion.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", " \\2"]]
  ]

  result = %Q[<div class="refererlist"><p class="referertitle">#{referer_today}</p>\n]
  result << %Q[<ul class="referer">\n]
  data = Array.new
  num = 0
  str = ""
  before_count = 0
  before_url = "aaaaaa"
  before_table = nil
  search_table = nil
  first = true
  search_result = ""
  diary.each_referer( limit ) do |count, ref|
	if ref =~ /#{before_url}/
	  search_table = before_table
	  same_before = true
	else
	  search_tables.each do |table|
		table[1..-1].each do |url|
		  if ref =~ /#{url[0]}/
			search_table = table
			before_url = url[0]
			break
		  end
		end
	  end
	  same_before = false
	end

	if search_table
	  if (same_before and before_count == count) or first
		first = false if first
	  else
		str.gsub!(/,$/, "")
		search_result << %Q[<li>#{before_count} x #{num} <a href="#{CGI::escapeHTML(before_table[0][1])}">[#{before_table[0][0]}] #{CGI::escapeHTML( str )}</a></li>\n]
		num = 0
		str = ""
      end
	  str << diary.disp_referer( search_table[1..-1], ref )
	  str << ","
	  num += 1
	  before_table = search_table
	  before_count = count
    else
      if str != "" and before_table
		str.gsub!(/,$/, "")
		search_result << %Q[<li>#{before_count} x #{num} <a href="#{CGI::escapeHTML(before_table[0][1])}">[#{before_table[0][0]}] #{CGI::escapeHTML( str )}</a></li>\n]
        num = 0
        str = ""
        first = true
      end
  	  result << %Q[<li>#{count} <a href="#{CGI::escapeHTML( ref )}">#{CGI::escapeHTML( diary.disp_referer( @referer_table, ref ) )}</a></li>\n]
    end
    search_table = nil
  end
  result << "<br />"
  result << search_result
  result + '</ul></div>'
end

end

