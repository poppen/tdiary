# $Revision: 1.13 $
# recent_comment3: 最近のツッコミをリストアップする
#   パラメタ:
#     max:           最大表示数(未指定時:3)
#     sep:           セパレータ(未指定時:空白)
#     date_format:   日付のフォーマット(未指定時:日記の日付表記+「時:分」)
#     except:        無視する名前(いくつもある場合は,で区切って並べる)
#
#   @secure = true な環境では動作しません．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'

RECENT_COMMENT3_CACHE = "#{@cache_path}/recent_comments"
RECENT_COMMENT3_NUM = 50

def recent_comment3(max = 3, sep = '&nbsp;',
		date_format = "(#{@date_format + ' %H:%M'})", *except )
	date_format = "(#{@date_format + ' %H:%M'})" unless date_format.respond_to?(:to_str)
	result = []
	idx = 0
	PStore.new(RECENT_COMMENT3_CACHE).transaction do |db|
		break unless db.root?('comments')
		db['comments'].each do |c|
			break if idx >= max or c.nil?
			comment, date, serial = c
			next unless comment.visible?
			next if except.include?(comment.name)
			str = %Q|<strong>#{idx += 1}.</strong><a href="#{@index}#{anchor date.strftime('%Y%m%d')}#c#{'%02d' % serial}" title="#{CGI::escapeHTML(comment.shorten( @conf.comment_length ))}">#{CGI::escapeHTML(comment.name)}#{comment.date.strftime(date_format)}</a>\n|
			result << str
		end
	end
	if result.size == 0
		''
	else
		result.join( sep )
	end
end

add_update_proc do
	if @mode == 'comment' and @comment
		comment = @comment
		serial = 0
		@diaries[@date.strftime('%Y%m%d')].each_comment(100) do
			serial += 1
		end
		PStore.new(RECENT_COMMENT3_CACHE).transaction do |db|
			db['comments'] = Array.new(RECENT_COMMENT3_NUM) unless db.root?('comments')
			if db['comments'][0].nil? or comment != db['comments'][0][0]
				db['comments'].unshift([comment, @date, serial]).pop
			end
		end
	end
end

# I want to use update_proc, but TDiaryShowComment doesn't call update_proc.
add_form_proc do |date|
	if @mode == 'showcomment'
		date = date.strftime('%Y%m%d')

		PStore.new(RECENT_COMMENT3_CACHE).transaction do |db|
			break unless db.root?('comments')

			@diaries[date].each_comment(100) do |dcomment|
				db['comments'].each do |c|
					break if c.nil?
					comment, cdate, serial = c
					next if cdate.strftime('%Y%m%d') != date
					if comment == dcomment and comment.date == dcomment.date
						comment.show = dcomment.visible?
						next
					end
				end
			end
		end
	end
end

# vim: ts=3
