# disp_referrer.rb $Revision: 1.12 $
# -pv-
#
# 名称：
# 本日のリンク元強化プラグイン
#
# 概要：
# 本日のリンク元でサーチエンジンの検索文字の文字化けを直します。
# また、サーチエンジンの検索結果を他のリンク元の下にまとめて表示します
# （デフォルト時）。
# なお、tDiary-1.4.x専用です。
#
# 使い方：
# 文字化けを直すのみ（表示はtDiaryの標準時と同様の並びにする）の場合は、
# tdiary.confに以下を追加してください。
# @options['disp_referrer.old'] = true
#
# 制限：
# EUC-JPで表現できない文字は表示できません。
#
# その他：
# http://home2.highway.ne.jp/mutoh/tools/ruby/ja/disp_referrer.html
# を参照してください。
#
# 著作権について：
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
=begin ChangeLog
2002-09-09  MUTOH Masao <mutoh@highway.ne.jp>
   * ロボットよけが効いていない不具合の修正(pointed out by TADA Tadashi<sho@spc.gr.jp>)
   * 検索キーワードが複数回ある場合の「x2」「x3」を、リンクの外に出した(proposed by TADA Tadashi<sho@spc.gr.jp>)
   * Web.escapeHTML()の処理が1カ所抜けていたので追加
   * version 2.2.2

2002-09-08  MUTOH Masao <mutoh@highway.ne.jp>
   * escapeモジュールがweb/ディレクトリ配下にインストールされる場合に対応
   Pointed out by Junichiro KITA <kita@kitaj.no-ip.com>.
	* tDiary-1.5.xで動作しなくなっていたバグの修正
   Fixed by Junichiro KITA <kita@kitaj.no-ip.com>.
   * version 2.2.1

2002-09-04  MUTOH Masao <mutoh@highway.ne.jp>
   * 高速化。アルゴリズム見直しおよび、fastesc導入。当社比(?)で実行時間を半分以下(45%程度)に削減できた。
   * Netscape検索改善
	* version 2.2.0

2002-08-30  MUTOH Masao <mutoh@highway.ne.jp>
   * @options['disp_referrer.deny_user_agents']追加。ロボットよけに用いる。
     ロボットよけはreferer_of_today_(short|long)のどちらでも行うようにした。
     デフォルトでGoogle, Goo, Hatena Antennaに対応。
     (Proposed by TADA Tadashi<sho@spc.gr.jp>)
   * @options["disp_referrer.table"]追加。検索結果ではなく通常のリンク元も検索結果部分同様
     サイト単位でまとめることができる。指定方法も検索テーブルと同様。
   * 全ての検索結果にリンクを貼るようにした。
     (Proposed by TADA Tadashi<sho@spc.gr.jp>)
   * 検索結果の方もヒット数の多い順にソートするようにした。
   * Netscape, Fresheye対応
   * Google, MSN表示改善

2002-08-22 TADA Tadashi <sho@spc.gr.jp>
	* support AlltheWeb search.
	* support tDiary 1.5 HTML.

2002-08-21 TADA Tadashi <sho@spc.gr.jp>
	* support tDiary 1.5.

2002-08-08  MUTOH Masao <mutoh@highway.ne.jp>
   * 検索結果の表示方法を変更。各検索エンジン毎に検索文字列を表示するようにした
   * 更新時は整形しないようにした(smbdさん要望)
   * 出力HTMLを改善
   * AOL検索追加
   * Lycos検索改善
   * version 2.1.0

2002-08-07  MUTOH Masao <mutoh@highway.ne.jp>
   * 表示対象のずれの修正
   * version 2.0.1

2002-08-06  MUTOH Masao <mutoh@highway.ne.jp>
   * google, Yahoo, Infoseek, Lycos, goo, OCN, excite, 
     msn, BIGLOBE, ODN, DIONからの検索結果を、同アクセス数単位でリンク一覧の
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
require 'nkf'
begin
   require 'escape'
rescue LoadError
   begin
      require 'web/escape'
   end
end

eval(<<TOPLEVEL_CLASS, TOPLEVEL_BINDING)
def Uconv.unknown_unicode_handler(unicode)
   if unicode == 0xff5e
      "〜"
   else
      raise Uconv::Error
   end
end
module DiaryBase
  REG_CHAR_UTF8 = /&#[0-9]+;/
  def referers
	newer_referer
	@referers
  end
  def disp_referer(table, ref)
	ret = Web.unescape(ref)
	if REG_CHAR_UTF8 =~ ref
	  ret.gsub!(REG_CHAR_UTF8){|v|
		Uconv.u8toeuc([$1.to_i].pack("U"))
	  }
	else
	  begin
		ret = Uconv.u8toeuc(ret)
	  rescue Uconv::Error
		ret = NKF::nkf('-e', ret)
	  end
	end
	
	table.each do |url, name|
	  regexp = Regexp.new(url, Regexp::IGNORECASE)
	  break if ret.gsub!(regexp, name)
	end
	ret
  end
end
TOPLEVEL_CLASS

# Deny user agents.
deny_user_agents = ["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]
if @options['disp_referrer.deny_user_agents']
  deny_user_agents += @options['disp_referrer.deny_user_agents']
end
@disp_referrer_antibots = Regexp::new("(" + deny_user_agents.join("|") + ")")

def disp_referrer_antibot?
  @disp_referrer_antibots =~ @cgi.user_agent
end

# Short referrer
alias disp_referrer_short referer_of_today_short
def referer_of_today_short(diary, limit)
   return '' if disp_referrer_antibot?
   disp_referrer_short(diary, limit)
end

# Long referrer
unless (@options['disp_referrer.old'] or @mode == "edit") #NEW VERSION

def disp_referrer_main(diary, refs, reg_table)
  result = Array.new
  reg_table.each do |title, *table|
	a_row = Array.new
	sum = 0
	table.each do |regval|
	  a_row_ref = refs.select{|item| /#{regval[0]}/i =~ item[1]}
	  if a_row_ref and a_row_ref.size > 0
		refs -= a_row_ref
		a_row << a_row_ref.collect{|item|
		  sum += item[0]
		  query = "<a href=\"#{Web.escapeHTML(item[1])}\">"
		  str = diary.disp_referer([regval], item[1])
		  str = "/" if str.size == 0
		  query << Web.escapeHTML(str) << "</a>"
		  query << " x" << item[0].to_s if item[0] > 1
		  query
		}
	  end
    end
	if a_row and a_row.size > 0
	  result << [sum, %Q[<li>#{sum} <a href="#{Web.escapeHTML(title[1])}">#{Web.escapeHTML(title[0])}</a> : #{a_row.join(", ")}</li>\n]]
    end
  end
  [result, refs]
end

def referer_of_today_long(diary, limit)
  return '' if not diary or diary.count_referers == 0 or disp_referrer_antibot?

  search_table = [
    [["Google検索","http://www.google.com/"],
	["^http://216.239.*/search.*q=([^&]*).*", "\\1"],
    ["^http://www.google..*/.*q=([^&]*).*", "\\1"]],
    [["Yahoo検索","http://www.yahoo.co.jp/"],
	["^http://google.yahoo.*/.*?p=([^&]*).*", "\\1"]],
    [["Infoseek検索","http://www.infoseek.co.jp/"],
	["^http://www.infoseek.co.jp/.*?qt=([^&]*).*", "\\1"]],
    [["Lycos検索","http://www.lycos.co.jp/"],
	["^http://.*lycos.*/.*?(query|q)=([^&]*).*", "\\2"]],
    [["goo検索","http://www.goo.ne.jp/"],
	["^http://(www|search).goo.ne.jp/.*?MT=([^&]*).*", "\\2"]],
    [["@nifty検索", "http://www.nifty.com/"],
	["^http://(search|asearch|www).nifty.com/.*?(q|Text)=([^&]*).*", "\\3"]],
    [["OCN検索", "http://www.ocn.ne.jp/"],
	["^http://ocn.excite.co.jp/search.gw.*search=([^&]*).*", "\\1"]],
    [["excite検索", "http://www.excite.co.jp/"],
	["^http://.*excite.*/.*?(search|s)=([^&]*).*", "\\2"]],
    [["msn検索", "http://www.msn.co.jp/home.htm"],
	["^http://.*search.msn.*?(q|MT)=([^&]*).*", "\\2"]],
    [["BIGLOBE検索", "http://www.biglobe.ne.jp/"],
	["^http://cgi.search.biglobe.ne.jp/cgi-bin/search.*?q=([^&]*).*", "\\1"]],
    [["テレコムサーチ", "http://www.odn.ne.jp/"],
	["^http://search.odn.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", "\\2"]],
    [["Netscape検索", "http://google.netscape.com/"],
	["^http://.*.netscape.com/.*(q|search)=([^&]*).*", "\\2"]],
    [["AOL検索", "http://www.aol.com/"],
	["^http://(?:aol)?search.*aol.com/.*query=([^&]*).*", "\\1"]],
    [["Fresheye検索", "http://www.fresheye.com/"],
	["^http://.*fresheye.*/.*kw=([^&]*).*", "\\1"]],
	[["AlltheWeb検索","http://www.alltheweb.com/"],
	["^http://www.alltheweb.com/.*?q=([^&]*).*", "\\1"]],
    [["DIONサーチ", "http://www.dion.ne.jp/"],
	["^http://dir.dion.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", "\\2"]]
  ]

  result = %Q[<div class="caption">#{referer_today}</div>\n]
  result << %Q[<ul>\n]

  #search part.
  refs = diary.referers.collect{|item| item[1..2].flatten}.sort.reverse
  search_result, refs = disp_referrer_main(diary, refs, search_table)

  #optional part.
  if @options["disp_referrer.table"]
	opt_result, refs = disp_referrer_main(diary, refs, @options["disp_referrer.table"])
  end

  #normal and optional part.
  normal_result = Array.new
  refs.each do |cnt, ref|
	normal_result << [cnt, %Q[<li>#{cnt} <a href="#{Web.escapeHTML(ref)}">#{Web.escapeHTML(diary.disp_referer(@referer_table, ref))}</a></li>\n]]
  end

  #show normal part.
  normal_result += opt_result if opt_result
  result << normal_result.sort{|a,b| - (a[0] <=> b[0])}.collect{|item| item[1]}.join << "</ul>\n<ul>\n"
  #show search part.
  result << search_result.sort{|a,b| - (a[0] <=> b[0])}.collect{|item| item[1]}.join << "</ul>"
end

end
