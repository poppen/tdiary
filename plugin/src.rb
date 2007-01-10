# src.rb $Revision: 1.3 $
#
# src: 外部ファイルを挿入する(HTMLエスケープ付き)
#   パラメタ:
#     file: ファイル名
#
# Copyright (c) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2.
#
def src( file )
	h( File::readlines( file ).join )
end

#
# src_inline: テキストを挿入する(HTMLエスケープ付き)
#
# パラメタ: テキスト文字列
#
def src_inline( str )
	h( str )
end

