#
# English resource of image plugin $Revision: 1.2 $
#

#
# Image Diary -  Upload images and insert to diary.
#
# image( number, 'altword', thumbnail ) - show a image.
#    number - image ID as 0, 1, 2...
#    altword - alt strings of the img element.
#    thumbnail - image ID of thumbnail (optional)
#
# image_left( number, 'altword', thumbnail ) - show a image with "class=left"
# image_right( number, 'altword', thumbnail ) - show a image with "class=right"
#
# image_link( number, 'desc' ) - make link to a image.
#    number - image ID as 0, 1, 2...
#    desc - description of the image.
#
# options in tdiary.conf:
#  @options['image.dir']
#     Directory of uploading images. Default is './images/'.
#     You have to set parmission to writable by web server.
#  @options['image.url']
#     URL of the image directory. Default is './images/'.
#  @options['image.maxnum']
#     Max of number of images per a day. Default is 1.
#     This option is effective in @secure = true.
#  @options['image.maxsize']
#     Max size of an image. Default is 10000 bytes.
#     This option is effective in @secure = true.
#
def image_error_num( max ); "You can add images upto #{max} par a day."; end
def image_error_size( max ); "You can add images upto #{max} bytes par an image."; end
def image_label_list_caption; 'Image Diary (List/Delete))'; end
def image_label_add_caption; 'Image Diary (Add)'; end
def image_label_description; 'Description of the image'; end
def image_label_add_plugin; 'Add to the article'; end
def image_label_delete; 'Delete checked images'; end
def image_label_only_jpeg; 'Only JPEG'; end
def image_label_add_image; 'Upload the image'; end
