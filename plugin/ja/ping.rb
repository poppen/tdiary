# ping.rb Japanese resources
begin
	require 'uconv'
	@ping_encode = 'UTF-8'
	@ping_encoder = Proc::new {|s| Uconv.euctou8( s ) }
rescue LoadError
	@ping_encode = @conf.encoding
	@ping_encoder = Proc::new {|s| s }
end

if /conf/ =~ @mode then
	@ping_label_conf = '更新通知'
	@ping_label_list = '通知先リスト'
	@ping_label_list_desc = '更新通知をするpingサービスのURLを、1行につき1つ入力してください。なお、あまりたくさん指定すると、途中でタイムアウトしてしまうかも知れません'
end

@ping_label_send = '更新情報を送る'
