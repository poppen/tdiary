# comment_mail-smtp.rb $Revision: 1.2 $
#
# SMTPプロトコルを使ってツッコミをメールで知らせる
#   入れるだけで動作する
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
#   @options['comment_mail.smtp_host']
#   @options['comment_mail.smtp_port']
#        それぞれ、メール送信に使うSMTPサーバのホスト名とポート番号。
#        無指定時はそれぞれ「'localhost'「と「25」。
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
def comment_mail( text )
	begin
		require 'net/smtp'
		host = @options['comment_mail.smtp_host'] || 'localhost'
		port = @options['comment_mail.smtp_port'] || 25
		Net::SMTP.start( host, port ) do |smtp|
			smtp.send_mail( text, @conf.author_mail, @options['comment_mail.receivers'] )
		end
	rescue
		$stderr.puts $!
	end
end

if @mode == 'comment' and @comment then
	@options['comment_mail.smtp_host'] ||= @conf.smtp_host || 'localhost'
	@options['comment_mail.smtp_port'] ||= @conf.smtp_port || 25
	comment_mail_send
end

