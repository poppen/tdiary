# comment_mail_sendmail.rb $Revision: 1.3 $
#
# sendmailを使ってツッコミをメールで知らせる
#   入れるだけで動作する。
#
# Options:
#   設定画面から指定できるもの(ツッコミメール系プラグイン共通):
#     @options['comment_mail.enable']
#          メールを送るかどうかを指定する。true(送る)かfalse(送らない)。
#          無指定時はfalse。
#     @options['comment_mail.header']
#          メールのSubjectに使う文字列。振り分け等に便利なように指定する。
#          実際のSubjectは「指定文字列:日付-1」のように、日付とコメント番号が
#          付く。ただし指定文字列中に、%に続く英字があった場合、それを
#          日付フォーマット指定を見なす。つまり「日付」の部分は
#          自動的に付加されなくなる(コメント番号は付加される)。
#          無指定時には空文字。
#     @options['comment_mail.receivers']
#          メールを送るアドレス文字列。カンマで区切って複数指定できる。
#          無指定時には日記筆者のアドレスになる。
#  
#   tdiary.confでのみ指定できるもの:
#     @options['comment_mail.sendmail']
#          sendmailコマンドのパスを指定する。
#          無指定時には「'/usr/sbin/sendmail'」。
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
def comment_mail( text, to )
	begin
		sendmail = @conf.options['comment_mail.sendmail'] || '/usr/sbin/sendmail'
		open( "|#{sendmail} #{to.join(' ')}", 'w' ) do |o|
			o.write( text )
		end
	rescue
		$stderr.puts $!
	end
end

if @mode =~ /^(comment|trackbackreceive)$/ then
	comment_mail_send
end

if @mode =~ /^(saveconf|conf)$/ then
	add_conf_proc( 'comment_mail', 'ツッコミメール' ) do
		comment_mail_basic_setting if @mode == 'saveconf'
		comment_mail_basic_html
	end
end
