# output_rdf: RDFファイル生成plugin 日本語リソース
#
# 材料
#
# 1. output_rdf.rb
# 2. uconv <http://www.yoshidam.net/Ruby.html#uconv>
#    uconvが見つからない場合はEUC-JPのRDFを吐き出します
#
# 調理法
#
# 1.
#  index.rb のあるディレクトリをwebサーバーから書き込みできるようにするか
#  index.rb のあるディレクトリに index.rdf というファイルをwebサーバーから
#  書き込みができるパーミッションで作成してください
#
#  なお、index.rdfは、@options['output_rdf.file']によってファイル名を変
#  更可能です
#
# 2.
#  プラグイン選択からout_put.rbを選択するか、pluginディレクトリにコピーしてください
#
# 3.
#  日記を書いてください
#
# 4.
#  rdfが見れるブラウザ等から http://日記のURL/index.rdf にアクセスしてください
#  
# 5.
#  なんかでてきたらOKです。おそらく。
#
begin
	require 'uconv'
	@output_rdf_encode = 'UTF-8'
	@output_rdf_encoder = Proc::new {|s| Uconv.euctou8( s ) }
rescue LoadError
	@output_rdf_encode = @conf.encoding
	@output_rdf_encoder = Proc::new {|s| s }
end

