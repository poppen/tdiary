# $Revision: 1.2 $
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

@recent_trackback3_cache = (@options['recent_trackback3.cache'] || "#{@cache_path}/recent_trackbacks")
@recent_trackback3_cache_size = @options['recent_trackback3.cache_size'] || 50

def recent_trackback3
	n = @options['recent_trackback3.n'] || 3
	sep = @options['recent_trackback3.sep'] || '&nbsp'
	date_format = @options['recent_trackback3.date_format'] || "(#{@date_format} %H:%M)"
	result = []
	idx = 0
	PStore.new(@recent_trackback3_cache).transaction do |db|
		break unless db.root?('trackbacks')
		db['trackbacks'].each do |tb|
			break if idx >= n or tb == nil
			trackback, date, serial = tb
			url, blog_name, title, excerpt = trackback.body.split(/\n/, 4)

			blog_name ||= ''
			title ||= ''
			excerpt ||= ''

			result << %Q|<strong>#{idx+1}.</strong><a href="#{@index}#{anchor date.strftime('%Y%m%d')}#t#{'%02d' % serial}" title="#{CGI::escapeHTML(@conf.shorten(excerpt, 60))}">#{CGI::escapeHTML(@conf.shorten([blog_name, title].join(":"),30))}#{trackback.date.strftime(date_format)}</a>\n|
			idx += 1
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
	if @mode == 'trackbackreceive'
	begin
		name = @conf.to_native(@cgi.params['name'][0])
		body = @conf.to_native(@cgi.params['body'][0])
		trackback = Comment.new(name, nil, body)
		serial = 0
		@diaries[@date.strftime('%Y%m%d')].each_visible_trackback( 100 ) {|tb| serial += 1}
		PStore.new(@recent_trackback3_cache).transaction do |db|
			db['trackbacks'] = Array.new(@recent_trackback3_cache_size) unless db.root?('trackbacks')
			if db['trackbacks'][0].nil? or trackback != db['trackbacks'][0][0]
				db['trackbacks'].unshift([trackback, @date, serial]).pop
			end
		end
	rescue
	STDERR.puts $!.message
	end
	end
end
# vim: ts=3
