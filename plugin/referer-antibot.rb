# referer-antibot.rb $Revision: 1.1 $
#
# 検索エンジンの巡回BOTには「本日のリンク元」を見せないようにする
# これにより、無関係な検索語でアクセスされることが減る(と予想される)
# pluginディレクトリに入れるだけで動作する
#
# オプション:
#   @options['disp_referrer.deny_user_agents']
#      ターゲットにする巡回BOTのuser agentを追加する配列。
#      このオプションはdisp_referrerプラグインと共通。
#      無指定時は["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]のみ。
#
# なお、disp_referrer.rbプラグインには同等の機能が含まれているので、
# disp_referrerを導入済みの場合には入れる必要はない
#
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Modified by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
=begin ChangeLog
2003-03-28 TADA Tadashi <sho@spc.gr.jp>
	* modify disp_referer.rb.
=end

# deny user agents
deny_user_agents = ["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]
deny_user_agents += @options['disp_referrer.deny_user_agents'] || []
@referer_antibots = Regexp::new( "(#{deny_user_agents.join( '|' )})" )

def referer_antibot?
	@referer_antibots =~ @cgi.user_agent
end

# short referer
alias referer_of_today_short_antibot_backup referer_of_today_short
def referer_of_today_short( diary, limit )
	return '' if referer_antibot?
	referer_of_today_short_antibot_backup( diary, limit )
end

# long referer
alias referer_of_today_long_antibot_backup referer_of_today_long
def referer_of_today_long( diary, limit )
	return '' if referer_antibot?
	referer_of_today_long_antibot_backup( diary, limit )
end
