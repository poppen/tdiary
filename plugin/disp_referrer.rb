# disp_referrer.rb
# -pv-
#
# 名称：
# 本日のリンク元強化プラグイン
#
# 概要：
# 文字化けしてしまっている本日のリンク元を直します。
# Google系検索エンジン、AOL、allthewebからのUTF-8文字列
# UTF-8実体参照の変換に対応しています。
#
# 使い方：
# Uconvモジュールをindex.rbと同じディレクトリにインストール
# する必要があります。
# http://www.ruby-lang.org/en/raa-list.rhtml?name=Uconv
#
# 詳しくは、
# http://home2.highway.ne.jp/mutoh/tools/ruby/ja/disp_referrer.html
# を参照してください。
# 
#
# 制限：
# EUC-JPで表現できない文字は表示できません。
#
# 著作権について：
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#
=begin ChangeLog
2002-07-30 MUTOH Masao  <mutoh@highway.ne.jp>
	* コメント追加

2002-07-24 MUTOH Masao  <mutoh@highway.ne.jp>
   * alltheweb対応
   * jp.aol.com, aol.com対応
   * 文字列変換の順序を変更
   * version 1.1.0

2002-07-20 MUTOH Masao  <mutoh@highway.ne.jp>
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
