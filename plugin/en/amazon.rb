#
# English resource of amazon plugin $Revision: 1.1 $
#

#
# isbn_image_left: show the item image of specified ISBN by class="left".
#   Parameter:
#     asin:    ASIN or ISBN
#     comment: comment (optional)
#
# isbn_image_right: 
#   Parameter:
#     asin:    ASIN or ISBN
#     comment: comment (optional)
#
# isbn_image: show the item image of specified ISBN by class="right".
#     asin:    ASIN or ISBN
#     comment: comment (optional)
#
# isbn: light version. it dose not access to amazon.
#     asin:    ASIN or ISBN
#     comment: comment
#
# options in tdiary.conf:
#   @options['amazon.aid']: Your Amazon Assosiate ID. This option can be
#                           changed in preferences page.
#   @options['amazon.hideconf']: When you want to prohibit changing amazon.aid
#                                via preferences page, set false.
#   @options['amazon.proxy']: HTTP proxy in "host:post" style.
#

@amazon_url = 'http://www.amazon.com/exec/obidos/ASIN'
@amazon_item_name = /^Amazon\.com: (.*)$/
@amazon_item_image = %r|(<img src="(http://images\.amazon\.com/images/P/(.*MZZZZZZZ_.jpg))".*?>)|i
@amazon_label_conf = 'Amazon'
@amazon_label_conf2 = 'Amazon Assosiate ID'
