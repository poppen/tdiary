# output_rdf.rb English resources
#
# How to use:
# 1. Enable to generate "index.rdf" file by your web server:
#      * chmod directory of index.rb existence to writable by web server
#      * or make "index.rdf" file into directory of index.rb existence as
#        writable by web server.
#    You can change the file name of "index.rdf" by the option 
#    @options['output_rdf.file'] in tdiary.conf. And you can also specify
#    image URL by @options['output_rdf.image'].
#
# 2. Select "output_rdf.rb" in Preferences or copy it into plugin directory.
#
# 3. Update your diary or post a TSUKKOMI.
#
# 4. Try to access to "http://YOUR_DIARY/index.rdf" by browser. If you can
#    see some text, it was succeed.
#  
@output_rdf_encode = "UTF-8"
@output_rdf_encoder = Proc::new {|s| s }

