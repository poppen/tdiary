# makelirs.rb $Revision: 1.2 $
#
# 更新情報をLIRSフォーマットのファイルに吐き出す
#
#   pluginディレクトリに置くだけで動作します。
#
#   tdiary.confにおいて、@options['makelirs.file']に
#   ファイル名を指定すると、そのファイルを出力先の
#   LIRSファイルとします。無指定時にはindex.rbと同じ
#   パスにantenna.lirsというファイルになります。
#   いずれも、Webサーバから書き込める権限が必要です。
#
# Copyright (C) 2002 by Kazuhiro NISHIYAMA
#
=begin ChangeLog
2002-10-06 TADA Tadashi <http://sho.tdiary.net/>
	* for tDiary 1.5.0.20021003.

2002-05-05 TADA Tadashi <http://sho.tdiary.net/>
	* support @options.

2002-05-04 Kazuhiro NISHIYAMA <zn@mbf.nifty.com>
	* create.
=end

add_update_proc do
	file = @options['makelirs.file'] || 'antenna.lirs'

	# create_lirs
	t = TDiaryLatest::new( @cgi, "latest.rhtml", @conf )
	body = t.eval_rhtml
	# escape comma
	e = proc{|str| str.gsub(/[,\\]/) { "\\#{$&}" } }
	lirs = "LIRS,#{t.last_modified.tv_sec},#{Time.now.tv_sec},0,#{body.size},#{e[@index_page]},#{e[@html_title]},#{e[@author_name]},,\n"
	File::open( file, 'w' ) do |o|
		o.puts lirs
	end
end

