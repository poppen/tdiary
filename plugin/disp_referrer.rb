# disp_referrer.rb $Revision: 1.26 $
# -pv-
#
# 名称：
# 本日のリンク元強化プラグイン
#
# 概要：
# 本日のリンク元でサーチエンジンの検索文字の文字化けを直します。
# また、サーチエンジンの検索結果を他のリンク元の下にまとめて表示します
# （デフォルト時）。
# なお、tDiary-1.5.x専用です。
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
# http://ponx.s5.xrea.com/hiki/ja/disp_referrer.rb.html
# を参照してください。
#
# 著作権について：
# Copyright (C) 2002,2003 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
=begin ChangeLog
2003-05-18 MUTOH Masao <mutoh@highway.ne.jp>
   * disp_referer2(by zundaさん)と同様アンテナを別カテゴリにするようにした。
   * Google検索でcacheの対応
   * はてなアンテナはデフォルトでリファラを解析するようにした。
   * @options["disp_referrer.no_antenna"]導入。アンテナを別カテゴリにしない
     従来通りの表示方法にしたい場合はtrueを指定する。
   * @options["disp_referrer.antenna_table"]導入。
   * version 2.4.0

2003-05-06 MUTOH Masao <mutoh@highway.ne.jp>
   * MSN検索改善 Pointed out by やまださん, yoshimiさん

2002-12-04 TADA Tadashi <sho@spc.gr.jp>
   * document update.
	
2002-10-13 MUTOH Masao <mutoh@highway.ne.jp>
   * Metcha SearchのURLが間違えていたのを修正。
	
2002-10-12 MUTOH Masao <mutoh@highway.ne.jp>
   * 「その他」が付く場合に、検索エンジン名の後ろに「:」が付かない不具合の修正(pointed out by TADA Tadashi <sho@spc.gr.jp>)
   * goo検索改善
   * version 2.3.1

2002-10-11 MUTOH Masao <mutoh@highway.ne.jp>
   * @options['disp_referrer.cols']追加。１つの検索エンジンで表示するカラム数を指定できるようにした(デフォルト10件)。
     カラムを超えた場合は、その他にまとめて表示される。
   * 検索時の繰り返し処理で全てのリンク元を走査し終わったらループを抜けるようなロジックを追加。
     これにより、頻度の低い検索エンジンを追加しても速度的にさほど差が出ないようになった。
   * TOCC/Search、Metcha Search、metacrawler検索、DOGPILE検索、NAXEARCH、overture検索、
     looksmart検索、i won_Search、EarthLink検索、About検索追加
   * Yahoo!、AOL、Google、 Biglobe、Infoseek、Fresheye、Netscape検索改善
   * version 2.3.0

2002-10-07 Junichiro Kita <kita@kitaj.no-ip.com>
   * add @options['disp_referrer.search_table']

2002-10-07 TADA Tadashi <sho@spc.gr.jp>
   * for tDiary 1.5.0.20021003.

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
module TDiary
  module DiaryBase
    @reg_char_utf8 = /&#[0-9]+;/
    def referers
      newer_referer
      @referers
    end
    def disp_referer(table, ref)
      ret = Web.unescape(ref)
      if @reg_char_utf8 =~ ref
        ret.gsub!(@reg_char_utf8){|v|
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

  @options['disp_referrer.cols'] = 10 unless @options['disp_referrer.cols']
  def disp_referrer_main(diary, refs, reg_table)
    result = Array.new
    reg_table.each do |title, *table|
      a_row = Array.new
      sum = 0
      etc_sum = 0 

      #ロジック的には１つの検索エンジンで複数の検索用正規表現が合った場合の事を
      #考慮して若干無駄なこと(一度all_numでそれぞれの部分配列を取得後、再度ソート
      #と再度部分配列の取得)をしているので注意
      all_num = @options['disp_referrer.cols']
      table.each do |regval|
        break if refs.size < 1
        reg = Regexp.new(regval[0], Regexp::IGNORECASE)
        a_row_ref = refs.select{|item| reg =~ item[1]}
        if a_row_ref and a_row_ref.size > 0
          if all_num < 0 or all_num > a_row_ref.size
            a_row_max = a_row_ref.size
          else
            a_row_max = all_num
          end
          
          refs -= a_row_ref
          a_row += a_row_ref[0...a_row_max].collect{|item|
            sum += item[0]
            query = "<a href=\"#{Web.escapeHTML(item[1])}\">"
            str = diary.disp_referer([regval], item[1])
            str = "/" if str.size == 0
            query << Web.escapeHTML(str) << "</a>"
            query << " x" << item[0].to_s if item[0] > 1
            [item[0], query]
          }
          if a_row_ref.size >= a_row_max 
            a_row_ref[a_row_max...a_row_ref.size].each {|item|
              sum += item[0]
              etc_sum += item[0]
            }
          end
        end
      end

      a_row.sort!{|a, b| -(a[0] <=> b[0])}

      a_row = a_row[0...all_num] if a_row and a_row.size > all_num and all_num > 0
      div = ":"
      if etc_sum > 0
        if all_num > 0
          a_row << [0, "<span class=\"disp-referrer-etc\">その他</span> x#{etc_sum}"]
        else
          a_row << [0, " "]
          div = ""
        end
      end
      if a_row and a_row.size > 0
        result << [sum, %Q[<li>#{sum} <a href="#{Web.escapeHTML(title[1])}">#{Web.escapeHTML(title[0])}</a> #{div} #{a_row.collect{|item| item[1]}.join(", ")}</li>\n]]
      end
    end
    [result, refs]
  end

  @disp_referrer_antenna_table = [
    [["tDiary.Net","http://www.tdiary.net/"],
      ["^http://www.tdiary.net/(.*)", "\\1"]],
  ]

  @disp_referrer_search_table = [
    [["Google検索","http://www.google.com/"],
      ["^http://.*(216.239|google).*q=cache:([^:]*):(.*?)(\s|\\+)([^&]*).*", "cache:\\5"],
      ["^http://.*(216.239|google).*q=([^&]*).*", "\\2"]],
    [["Yahoo検索","http://www.yahoo.co.jp/"],
      ["^http://.*.yahoo.*?p=([^&]*).*", "\\1"]],
    [["Infoseek検索","http://www.infoseek.co.jp/"],
      ["^http://.*infoseek.*?qt=([^&]*).*", "\\1"]],
    [["Lycos検索","http://www.lycos.co.jp/"],
      ["^http://.*lycos.*/.*?(query|q)=([^&]*).*", "\\2"]],
    [["goo検索","http://www.goo.ne.jp/"],
      ["^http://.*goo.ne.jp/.*?MT=([^&]*).*", "\\1"]],
    [["@nifty検索", "http://www.nifty.com/"],
      ["^http://(search|asearch|www).nifty.com/.*?(q|Text)=([^&]*).*", "\\3"]],
    [["OCN検索", "http://www.ocn.ne.jp/"],
      ["^http://ocn.excite.co.jp/search.gw.*search=([^&]*).*", "\\1"]],
    [["excite検索", "http://www.excite.co.jp/"],
      ["^http://.*excite.*?(search|s)=([^&]*).*", "\\2"]],
    [["msn検索", "http://www.msn.co.jp/home.htm"],
      ["^http://.*search.msn.*?[\?&](q|MT)=([^&]*).*", "\\2"]],
    [["BIGLOBE検索", "http://www.biglobe.ne.jp/"],
      ["^http://cgi.search.biglobe.ne.jp/cgi-bin/search.*?(q|key)=([^&]*).*", "\\2"]],
    [["テレコムサーチ", "http://www.odn.ne.jp/"],
      ["^http://search.odn.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", "\\2"]],
    [["Netscape検索", "http://google.netscape.com/"],
      ["^http://.*.netscape.com/.*(query|q|search)=([^&]*).*", "\\2"]],
    [["DIONサーチ", "http://www.dion.ne.jp/"],
      ["^http://dir.dion.ne.jp/LookSmartSearch.jsp.*(key|QueryString)=([^&]*).*", "\\2"]],
    [["Metcha Search","http://bach.scitec.kobe-u.ac.jp/"],
      ["^http://bach.scitec.kobe-u.ac.jp/cgi-bin/metcha.cgi?q=([^&]*).*", "\\1"]],
    [["AOL検索", "http://www.aol.com/"],
      ["^http://.*aol.com/.*query=([^&]*).*", "\\1"]],
    [["Fresheye検索", "http://www.fresheye.com/"],
      ["^http://.*fresheye.*kw=([^&]*).*", "\\1"]],
    [["AlltheWeb検索","http://www.alltheweb.com/"],
      ["^http://www.alltheweb.com/.*?q=([^&]*).*", "\\1"]],
    [["TOCC/Search","http://www.tocc.co.jp/"],
      ["^http://www.tocc.co.jp.*QRY=([^&]*).*", "\\1"]],
    [["EarthLink検索","http://www.earthlink.net/"],
      ["^http://.*earthlink.*q=([^&]*).*", "\\1"]],
    [["i won_Search","http://home.iwon.com/"],
      ["^http://.*iwon.*searchfor=([^&]*).*", "\\1"]],
    [["metacrawler検索","http://www.metacrawler.com/"],
      ["^http://.*metacrawler.com/texis/search?q=([^&]*).*", "\\1"]],
    [["DOGPILE検索","http://www.dogpile.com/"],
      ["^http://search.dogpile.com/texis/search.q=([^&]*).*", "\\1"]],
    [["NEXEARCH","http://www.naver.co.jp/"],
      ["^http://search.naver.*query=([^&]*).*", "\\1"]],
    [["overture検索","http://www.overture.com/"],
      ["^http://overture.*Keywords=([^&]*).*", "\\1"]],
    [["About検索","http://www.about.com/"],
      ["^http://.*about.*terms=([^&]*).*", "\\1"]],
    [["looksmart検索","http://www.looksmart.com/"],
      ["^http://www.looksmart.com.*key=([^&]*).*", "\\1"]]
  ]

  def disp_referrer_create_ul(title, ary)
    ary.sort!{|a,b| - (a[0] <=> b[0])}
    ary.collect!{|item| item[1]} if ary
    result = %Q[<div class="caption">#{title}</div>\n]
    result << "<ul>\n"
    result << ary.join if ary 
    result << "</ul>\n"
  end

  def disp_referrer_normal(diary, refs, table)
    result = Array.new
    refs.each do |cnt, ref|
      result << [cnt, %Q[<li>#{cnt} <a href="#{Web.escapeHTML(ref)}">#{Web.escapeHTML(diary.disp_referer(table, ref))}</a></li>\n]]
    end
    result
  end

  def referer_of_today_long(diary, limit)
    return '' if not diary or diary.count_referers == 0 or disp_referrer_antibot?

    if @options["disp_referrer.search_table"]
      @disp_referrer_search_table += @options["disp_referrer.search_table"]
    end

    #search part.
    refs = diary.referers.collect{|item| item[1..2].flatten}
    refs.sort!{|a,b| -(a[0] <=> b[0])} if refs
    
    search_result, refs = disp_referrer_main(diary, refs, @disp_referrer_search_table)

    #antenna part.
    if @options["disp_referrer.antenna_table"]
      @disp_referrer_antenna_table += @options["disp_referrer.antenna_table"]
    end
    antenna_result, refs = disp_referrer_main(diary, refs, @disp_referrer_antenna_table)

    #main part.
    if @options["disp_referrer.table"]
      main_result, refs = disp_referrer_main(diary, refs, @options["disp_referrer.table"])
    end
    main_result = Array.new unless main_result

    antenna_word_regexp = /(アンテナ|あんてな)/
    antenna_url_regexp = %r{link-ruby|a.hatena.ne.jp|iraira|ntenna|/a/$|/tama/$}
    #separate main/antenna part
    @referer_table << ["^http://a.hatena.ne.jp/([^/]+)/?.*", 'はてなアンテナ(\1さん)']
    refs.each do |cnt, ref|
      if ref =~ antenna_url_regexp and ! @options["disp_referrer.no_antenna"]
        antenna_result << [cnt, %Q[<li>#{cnt} <a href="#{Web.escapeHTML(ref)}">#{Web.escapeHTML(diary.disp_referer(@referer_table, ref))}</a></li>\n]]
      else
        ret = diary.disp_referer(@referer_table, ref)
        if ret =~ antenna_word_regexp and ! @options["disp_referrer.no_antenna"]
          antenna_result << [cnt, %Q[<li>#{cnt} <a href="#{Web.escapeHTML(ref)}">#{Web.escapeHTML(ret)}</a></li>\n]]
        else
          main_result << [cnt, %Q[<li>#{cnt} <a href="#{Web.escapeHTML(ref)}">#{Web.escapeHTML(ret)}</a></li>\n]]
          end
      end
    end

    #show main and part.
    result = ""
    result << disp_referrer_create_ul(referer_today, main_result) if main_result.size > 0

    #show antenna part
    result << disp_referrer_create_ul("アンテナ", antenna_result) if antenna_result.size > 0

    #show search part.
    result << disp_referrer_create_ul("検索", search_result) if search_result.size > 0

    result
  end
end
