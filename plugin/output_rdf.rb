#
# output_rdf: RDFファイル生成plugin
#
# 材料
#
# 1. output_rdf.rb
# 2. uconv <http://www.yoshidam.net/Ruby.html#uconv>
#
# 調理法
#
# 1.
#  tdiary.rb のあるディレクトリをwebサーバーから書き込みできるようにするか
#  tdiary.rb のあるディレクトリに t.rdf というファイルをwebサーバーから
#  書き込みができるパーミッションで作成してください
#
# 2.
#  忘れずに output_rdf.rb を plugin に ほオリコンでください
#
# 3.
#  日記を書いてください
#
# 4.
#  rdfが見れるブラウザ等から http://日記のURL/t.rdf にアクセスしてください
#  
# 5.
#  なんかでてきたらOKです。おそらく。
#
# Copyright (c) 2003 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
# Distributed under the GPL

=begin ChangeLog
2003-01-27 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
	* reorder apply_plugin.
	
2003-01-21 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
	* no requirement of diary.rrdf.
	* rss version 1.0.
	
2003-01-11 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
	* use Plugin#apply_plugin.
	* compatible defaultio
=end
 
require 'uconv'

add_update_proc( Proc::new do
	if @mode == 'append' || @mode == 'replace' then
		date = sprintf( "%4d%02d%02d", @cgi['year'][0], @cgi['month'][0],@cgi['day'][0] )
	else
		date=@cgi['date'][0]
	end
	diary = @diaries[date]
	host  = ENV['HTTP_HOST'] 
	path  = ENV['REQUEST_URI']
   	path  = path[0..path.rindex("/")]
   	uri   = "#{host}#{path}#{@index}"
	r = ""
	r <<<<-RDF
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF 
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns="http://purl.org/rss/1.0/"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
>
 <channel>
   <title lang="ja">#{@html_title}</title>
   <link>http://#{uri}</link>
   <description lang="ja">#{@html_title}</description>
   <dc:date>#{Time.now.strftime('%Y-%m-%dT%H:%M')}</dc:date>
 </channel>
	RDF
 	idx = 1
 	diary.each_section do |section|
		if section.subtitle then
		r <<<<-RDF
 <item>
 <title lang="ja">#{CGI::escapeHTML(apply_plugin(section.subtitle).gsub(/<.+?>/,''))}</title>
 <link>http://#{uri}#{anchor "#{date}\#p#{'%02d' % idx}"}</link>
 <description>#{CGI::escapeHTML(shorten(apply_plugin(section.body)))}</description>
 </item>
 		RDF
		end
  		idx += 1
	end
	if diary.count_comments > 0 then
	   	r <<<<-RDF
 <item>
 <title lang="ja">#{comment_today}#{comment_total(diary.count_comments)}</title>
		RDF
  		diary.each_comment_tail( 1 ) do |comment,idx|
		if comment.visible? then
		r <<<<-RDF
 <link>http://#{uri}#{anchor "#{date}\#c#{'%02d' % idx}"}</link>
 <description>#{CGI::escapeHTML( comment.name )}[#{CGI::escapeHTML(shorten(comment.body))}]</description>
		RDF
  		end
		end
 	r << " </item>\n"
 	end
	r << "</rdf:RDF>"
	r = Uconv.euctou8(r)
	File::open( "t.rdf", 'w' ) do |o|
		o.puts r
	end
end )
