# ping.rb Chinese resources
require 'iconv'
@ping_encode = 'UTF-8'
@ping_encoder = Proc::new {|s| Iconv::conv( 'UTF-8', 'Big5', s ) }

if /conf/ =~ @mode then
	@ping_label_conf = 'Update ping'
	@ping_label_list = 'List of ping servers'
	@ping_label_list_desc = 'Specify URLs of ping request.'
	@ping_label_timeout = 'Timeout(sec)'
end

@ping_label_send = 'Sending ping'
