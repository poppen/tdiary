# html_anchor $Revision: 1.1 $
#
# anchor: アンカーを「YYYYMMDD.html」「YYYYMM.html」形式に置き換える
#         tDiaryから自動的に呼び出されるので、プラグインファイルを
#         設置するだけでよい。mod_rewriteと合わせて利用する。
#         参照: http://sho.tdiary.net/20020301.html#p04
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL
#

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

