# recent_comment.rb $Revision: 1.5 $
#
# recent_comment: 最近のツッコミをリストアップする
#   パラメタ:
#     max:    最大表示数(未指定時:3)
#     sep:    nil
#     form:   日付のフォーマット(未指定時:(日記の日付表記 時:分))
#     except: 無視する名前(未指定時:nil)
#
# Copyright (C) 2002 by zoe <http://www.kasumi.sakura.ne.jp/~zoe/tdiary/>
#
# Original: http://www.kasumi.sakura.ne.jp/~zoe/tdiary/?date=20011225#p07
# Modified: by TADA Tadashi <http://sho.tdiary.net/>
# Modified: by kitaj <http://kitaj.no-ip.com/>
#
def recent_comment( max = 3, sep = 'OBSOLUTE', form = nil, except = nil )
	form = "(#{@date_format + ' %H:%M'})" unless form
	comments = []
	date = {}
	index = {}
	@diaries.each_value do |diary|
		next unless diary.visible?
		diary.each_comment_tail( max ) do |comment, idx|
			if except && (/#{except}/ =~ comment.name)
				next
			end
			comments << comment
			date[comment.date] = diary.date
			index[comment.date] = idx
		end
	end
	result = []
	comments.sort{|a,b| (a.date)<=>(b.date)}.reverse.each_with_index do |com,idx|
		break if idx >= max
		str = ''
	  	str << %Q[<li><a href="#{@index}#{anchor date[com.date].strftime( '%Y%m%d' )}#c#{'%02d' % index[com.date]}"]
		str << %Q[ title="#{CGI::escapeHTML( com.shorten( @conf.comment_length ) )}">]
		str << %Q[#{CGI::escapeHTML( com.name )}]
		str << %Q[#{com.date.dup.strftime( form )}</a></li>\n]
		result << str
	end
	%Q|<ol class="recent-comment">\n| + result.join( '' ) + "</ol>\n"
end

