# yyyymmdd.rb $Revision: 1.1 $
#
# yyyymmdd: アンカーのURLをYYYYMMDD.html形式に変更する
#   pluginディレクトリにコピーするだけでOK
#   このプラグインを入れることで、月ごと、日ごとのページのURLが
#   YYYYMM.htmlやYYYYMMDD.htmlを指すように変更される。このURLで
#   呼び出されてもきちんと動作するように、Webサーバ側の変更も必
#   要。Apacheの場合はmod_rewriteを使って書き換えることを推奨す
#   るが、ErrorDocumentを使った方法もある(dot.htaccessのコメント
#   を参照)。
# 
# Copyright (C) 2002 by TADA Tadashi <sho@spc.gr.jp>
#
=begin ChangeLog
2002-10-12 TADA Tadashi <sho@spc.gr.jp>
	* 1st release.
=end

def anchor( s )							 
	if /^(\d+)#?([pc]\d*)?$/ =~ s then
		if $2 then
			"#$1.html##$2"
		else	  
			"#$1.html"
		end											  
	else 
		""
	end
end			  

