# $Revision: 1.4 $
# recent_trackback3: 最近のツッコミをリストアップする
#
# Options:
#	@options['recent_trackback3.cache']:
#		受信したTrackBackを保存しておくファイル名．(@cache_path/recent_trackbacks)
#
#	@options['recent_trackback3.cache_size']:
#		キャッシュに保存しておくTrackBackの件数．(50)
#
#	@options['recent_trackback3.n']:
#		表示するTrackBack件数．(3)
#
#	@options['recent_trackback3.sep']:
#		各TrackBack間に挿入する文字列．(&nbsp)
#
#	@options['recent_trackback3.date_format']:
#		日付フォーマット．("(#{@date_format} %H:%M)")
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'


def recent_trackback3_format(format, *args)
	format.gsub(/\$(\d)/) {|s| args[$1.to_i - 1]}
end

def recent_trackback3_init
	@conf['recent_trackback3.cache'] ||= "#{@cache_path}/recent_trackbacks"
	@conf['recent_trackback3.cache_size'] ||= 50
	@conf['recent_trackback3.n'] ||= 3
	@conf['recent_trackback3.sep'] ||= '&nbsp'
	@conf['recent_trackback3.date_format'] ||= "(#{@date_format} %H:%M)"
	@conf['recent_trackback3.format'] ||= '<strong>$1.</strong><a href="$2" title="$3">$4 $5</a>'
end

def recent_trackback3
	recent_trackback3_init

	cache = @conf['recent_trackback3.cache']
	n = @conf['recent_trackback3.n']
	sep = @conf['recent_trackback3.sep']
	date_format = @conf['recent_trackback3.date_format']
	format = @conf['recent_trackback3.format']
	result = []
	idx = 0

	PStore.new(cache).transaction do |db|
		break unless db.root?('trackbacks')
		db['trackbacks'].each do |tb|
			break if idx >= n or tb == nil
			trackback, date, serial = tb
			next unless trackback.visible_true?
			url, blog_name, title, excerpt = trackback.body.split(/\n/, 4)

			a = @index + anchor("#{date.strftime('%Y%m%d')}#t#{'%02d' % serial}")
			popup = CGI.escapeHTML(@conf.shorten(excerpt, 60))
			str = [blog_name, title].compact.join(":").sub(/:$/, '')
			str = url if str == ''
			str = CGI.escapeHTML(@conf.shorten(str, 30))
			date_str = trackback.date.strftime(date_format)
			idx += 1

			result << recent_trackback3_format(format, idx, a, popup, str, date_str)
		end
		db.abort
	end
	if result.size == 0
		''
	else
		result.join(sep)
	end
end

add_update_proc do
	if @mode == 'trackbackreceive' and @comment
		recent_trackback3_init
		cache = @conf['recent_trackback3.cache']
		cache_size = @conf['recent_trackback3.cache_size']
		trackback = @comment
		serial = 0
		@diaries[@date.strftime('%Y%m%d')].each_visible_trackback( 100 ) {|tb, idx| serial += 1}
		PStore.new(cache).transaction do |db|
			db['trackbacks'] = Array.new(cache_size) unless db.root?('trackbacks')
			if db['trackbacks'][0].nil? or trackback != db['trackbacks'][0][0]
				db['trackbacks'].unshift([trackback, @date, serial]).pop
			end
		end
	end
end

# fix me!
# I want to use update_proc, but TDiaryShowComment doesn't call update_proc.
add_form_proc do |date|
	if @mode == 'showcomment'
		recent_trackback3_init
		cache = @conf['recent_trackback3.cache']
		cache_size = @conf['recent_trackback3.cache_size']
		date = date.strftime('%Y%m%d')

		PStore.new(cache).transaction do |db|
			break unless db.root?('trackbacks')

			@diaries[date].each_comment(100) do |dtrackback|
				db['trackbacks'].each do |c|
					break if c.nil?
					trackback, tbdate, serial = c
					next if tbdate.strftime('%Y%m%d') != date
					if trackback == dtrackback and trackback.date == dtrackback.date
						trackback.show = dtrackback.visible_true?
						next
					end
				end
			end
		end
	end
end

if @mode == 'saveconf'
def saveconf_recent_trackback3
	@conf['recent_trackback3.n'] = @cgi.params['recent_trackback3.n'][0].to_i
	@conf['recent_trackback3.sep'] = @cgi.params['recent_trackback3.sep'][0]
	@conf['recent_trackback3.date_format'] = @cgi.params['recent_trackback3.date_format'][0]
	@conf['recent_trackback3.format'] = @cgi.params['recent_trackback3.format'][0]
end
end
# vim: ts=3
