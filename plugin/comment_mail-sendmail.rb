# comment_mail_sendmail.rb $Revision: 1.1 $
#
# sendmailを使ってツッコミをメールで知らせる
#   入れるだけで動作する。
#
# Options:
#   @options['comment_mail.header']
#        メールのSubjectに使う文字列。振り分け等に便利なように指定する。
#        実際のSubjectは「指定文字列:日付-1」のように、日付とコメント番号が
#        付く。ただし指定文字列中に、%に続く英字があった場合、それを
#        日付フォーマット指定を見なす。つまり「日付」の部分は
#        自動的に付加されなくなる(コメント番号は付加される)。
#        無指定時には空文字。
#   @options['comment_mail.receivers']
#        メールを送るアドレスの配列。無指定時には日記筆者のアドレスになる。
#   @options['comment_mail.sendmail']
#        sendmailコマンドのパスを指定する。
#        無指定時には「'/usr/sbin/sendmail'」。
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
def comment_mail( text )
	begin
		sendmail = @options['comment_mail.sendmail'] || '/usr/sbin/sendmail'
		receivers = @options['comment_mail.receivers']
		open( "|#{sendmail} #{receivers.join(' ')}", 'w' ) do |o|
			o.write( text )
		end
	rescue
		$stderr.puts $!
	end
end

if @mode == 'comment' and @comment then
	comment_mail_send
end
