#
# English resource of amazon plugin $Revision: 1.2 $
#

#
# isbn_image_left: 指定したISBNの書影をclass="left"で表示
#   パラメタ:
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(省略可)
#
# isbn_image_right: 指定したISBNの書影をclass="right"で表示
#   パラメタ:
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(省略可)
#
# isbn_image: 指定したISBNの書影をclass="amazon"で表示
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(省略可)
#
# isbn: amazonにアクセスしない簡易バージョン。
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(必須)
#
#   ASINとはアマゾン独自の商品管理IDです。
#   書籍のISBNをASINに入力すると書籍が表示されます。
#
#   それぞれ商品画像が見つからなかった場合は
#       <a href="amazonのページ">商品名</a>
#   のように商品名を表示します。
#   コメントが記述されている場合は商品名がコメントの内容に変わります。
#
# tdiary.confにおける設定:
#   @options['amazon.aid']:      アソシエイトIDを指定することで、自分のア
#                                ソシエイトプログラムを利用できます
#                                このオプションは設定画面から変更可能です
#   @options['amazon.hideconf']: 設定画面上でアソシエイトIDを入力不可能
#                                にしたい場合、trueに設定します
#   @options['amazon.proxy']:    「host:post」形式でHTTP proxyを指定すると
#                                Proxy経由でAmazonの情報を取得します
#   @options['amazon.imgsize']:  表示するイメージのサイズを指定します
#                                (0:大  1:中  2:小)
#   @options['amazon.hidename']: class="amazon"のときに商品名を表示したく
#                                ない場合、trueに設定します
#   @options['amazon.nodefault']: デフォルトのイメージを表示したくない場合
#                                 trueに設定します
#
#
# 注意：著作権が関連する為、www.amazon.co.jpのアソシエイトプログラムを
# 確認の上利用して下さい。
#

@amazon_url = 'http://www.amazon.co.jp/exec/obidos/ASIN'
@amazon_item_name = /^Amazon.co.jp： (.*)<.*$/
@amazon_item_image = %r|(<img src="(http://images-jp\.amazon\.com/images/P/(.*MZZZZZZZ.jpg))".*?>)|i
@amazon_label_conf ='Amazonプラグイン'
@amazon_label_aid = 'AmazonアソシエイトIDの指定'
@amazon_label_imgsize = '表示するイメージのサイズ'
@amazon_label_large = '大きい'
@amazon_label_regular = '普通'
@amazon_label_small = '小さい'
@amazon_label_title = 'isbn_imageプラグインで商品名を'
@amazon_label_hide = '表示しない'
@amazon_label_show = '表示する'
@amazon_label_notfound = 'イメージが見つからないときは'
@amazon_label_usetitle = '商品名を表示する'
@amazon_label_usedefault = 'デフォルトのイメージを使う'
@amazon_label_clearcache = 'キャッシュの削除'
@amazon_label_clearcache_desc = 'イメージ関連情報のキャッシュを削除する(Amazon上の表示と矛盾がある場合に試して下さい)'
