# tlink.rb $Revision: 1.3 $
#
# title 属性付 anchor plugin
#
# 使い方
#   <%= tlink( "URL", "文字列", "title 属性の中身（省略可）" ) %>
#
#   第 3 パラメータを省略した時、URL の末尾が c#?? ならば、
#   そのツッコミの内容が最初の行だけ表示されます。
#   末尾が p#?? ならば、サブタイトルがあればサブタイトルが、
#   なければ最初のパラグラフが表示されます。
#
#   例. <%= tlink( "http://tdiary.tdiary.net/20020131.html#c01", "このツッコミ" ) %>
#       出力結果:
#       <a href="http://tdiary.tdiary.net/20020131.html#c01", title="テストでござるよ">このツッコミ</a>
#
# Copyright(C) 2002 NT <nt@24i.net>
# Distributed under the GPL.
#
# Modified: by abbey <inlet@cello.no-ip.org>
#
=begin ChangeLog
2002-04-20 NT <nt@24i.net>
	* change User-Agent
	* modify some regular expressions

2002-04-19 NT <nt@24i.net>
	* modify some regular expressions
	* add User-Agent

2002-04-18 abbey <inlet@cello.no-ip.org>
	* adapt to port numbers except 80
	* adapt to #pXX

2002-04-17 NT <nt@24i.net>
	* create
=end

require 'net/http'
require 'cgi'
require 'kconv'

def getcomment( url )
  result = ""
  agent = { "User-Agent" => "DoCoMo (compatible; tDiary plugin; tlink;)" }
  host, path, frag = url.scan( %r[http://(.*?)/(.*)#((?:p|c)\d\d)] )[0]
  if /p0/ =~ frag
    frag = "(" + frag + "|" + frag.sub( /p/, "p#" ).sub( /#0/, "#" ) + ")"
  end
  port = 80
  if /(.*):(\d+)/ =~ host
    host = $1
    port = $2
  end
  hata = 0
  Net::HTTP.start( host, port ) { |http|
    response , = http.get( "/#{path}", agent )
      response.body.each { |line|
        if %r[<A NAME="#{frag}] =~ line
            if %r[<P><A NAME="p#?\d+">(?:.*?)</A> (.*?)</P>] =~ line.toeuc
              result = $1
	      break
            else
              hata = 1
            end
        elsif hata == 1 && %r[^\t*(.*?)<BR>] =~ line.toeuc
            result = $1
            hata = 0
	    break
        end
      }
  }

  result = CGI::escapeHTML( result.gsub( %r[</?[aA](.*?)>], "" ) ).gsub( /&amp;nbsp;/, " " )
end

def tlink( url, str, title = nil )
  unless title
    title = getcomment( url )
  end

  %Q[<a href="#{url}", title="#{title}">#{str}</a>]
end

