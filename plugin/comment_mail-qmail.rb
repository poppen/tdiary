# comment_mail_qmail.rb $Revision: 1.1 $
#
# qmailを使ってツッコミをメールで知らせる
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
#   @options['comment_mail.qmail']
#        qmail_injectコマンドのパスを指定する。
#        無指定時には「'/var/qmail/bin/qmail-inject'」。
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
def comment_mail( text )
	begin
		qmail = @options['comment_mail.qmail'] || '/var/qmail/bin/qmail-inject'
		receivers = @options['comment_mail.receivers']
		open( "|#{qmail} #{receivers.join(' ')}", 'w' ) do |o|
			o.write( text )
		end
	rescue
		$stderr.puts $!
	end
end

if @mode == 'comment' and @comment then
	comment_mail_send
end

