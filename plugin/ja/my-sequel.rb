#
# ja/my-sequel.rb
# $Revision: 1.1 $
#
# show links to follow-up entries
#
# Copyright 2006 zunda <zunda at freeshell.org> and
#                NISHIMURA Takashi <nt at be.to>
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work under the terms
# of GPL version 2.
#

@my_sequel_plugin_name = '後日談へのリンク'
@my_sequel_description ||= <<_END
<p>myプラグインで過去の日記に言及すると、その日記からのリンクを表示します。</p>
<p>デフォルトの設定に戻す時は、デフォルトに戻したい設定の文字列を削除して「OK」ボタンを押してください。</p>
_END
@my_sequel_default_hash ||= {
	:label => {
		:title => 'ラベル',
		:default => 'つづき: ',
		:description => '後日談へのリンクの前に表示される文字列です。',
		:index => 1,
	},
	:date_format => {
		:title => 'リンク文字列',
		:default => @date_format,
		:description => '後日談へのリンクの文字列の書式です。%で始まる英字は次のように変換されます: 「%Y」(西暦年)、「%m」(月数値)、「%b」(短月名)、「%B」(長月名)、「%d」(日)、「%a」(短曜日名)、「%A」(長曜日名)。',
		:index => 2,
	},
	:inner_css => {
		:title => 'スタイル',
		:default => <<'_END',
font-size: 75%;
text-align: right;
margin: 0px;
_END
		:description => '後日談へのリンクに設定されるCSSです。div.sequelに適用されます。',
		:index => 3,
		:textarea => {:rows => 5},
	},
}
