# kw.rb $Revision: 1.4 $
#
# kw: keyword link generator
#   Parameters:
#     keyword: keyword or InterWikiName (separated by ':').
#
# @options['kw.dic']
#   array of dictionary table array. an item of array is:
#
#       [key, URL, style]
#
#   key:   nil or string of key.
#          If keyword is 'foo', it has key nil.
#          If keyword is 'google:foo', it has key 'google'.
#   URL:   the URL for link. '$1' is replace by keyword.
#   style: encoding style as: 'euc-jp', 'sjis', 'jis' or nil.
#
#   if there isn't @options['kw.dic'], the plugin links to google.
#
# @options['kw.show_inter']
#   Show InterWikiName.
#   If this options is true, the keyword 'google:foo' shows 'google:foo'.
#   But it is false, that shows only 'foo'.
#   The default of this option is true.
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# You can distribute this under GPL.
#

def kw( keyword )
	unless @kw_dic then
		@kw_dic = {nil => ['http://www.google.com/search?ie=euc-jp&amp;q=$1', 'euc-jp']}
		if @options['kw.dic'] then
			@options['kw.dic'].each do |dic|
				@kw_dic[dic[0]] = dic[1..-1]
			end
		end
	end

	show_inter = @options['kw.show_inter'] == nil ? true : @options['kw.show_inter']

	inter, key = keyword.split( /:/, 2 )
	unless key then
		inter = nil
		key = keyword
	end
	keyword = key unless show_inter
	begin
		key = CGI::escape( case @kw_dic[inter][1]
			when 'euc-jp'
				#NKF::nkf( '-e', key )
				key
			when 'sjis'
				NKF::nkf( '-s', key )
			when 'jis'
				NKF::nkf( '-j', key )
			else # none
				key
		end )
	rescue NameError
		inter = nil
		retry
	end
	%Q[<a href="#{@kw_dic[inter][0].sub( /\$1/, key )}">#{keyword}</a>]
end

#
# config
#
def kw_label
	if @lang == 'en' then
		"Keyword plugin"
	else
		"キーワードプラグイン"
	end
end
def kw_desc
	if @lang == 'en' then
		<<-HTML
		<p>kw(KeyWord) plugin generate a Link by simple words. You can specify keywords		
		as space sepalated value: "keyword URL". For example,</p>
		<pre>google http://www.google.com/search?q=$1</pre>
		<p>then you specify in your diary as:</p>
		<pre>&gt;%=kw 'google:tdiary' %&lt;</pre>
		<p>so it will be translated to link of seraching 'tdiary' at Google.</p>
		HTML
	else
		<<-HTML
		<h3>リンクリストの指定</h3>
		<p>特定のサイトへのリンクを、簡単な記述で生成するためのプラグイン(kw)です。
		「キー URL エンコードスタイル」と空白で区切って指定します。例えば、</p>
		<pre>google http://www.google.com/search?ie=euc-jp&amp;q=$1 euc-jp</pre>
		<p>と指定すると、</p>
		<pre>&lt;%=kw('google:tdiary')%&gt;</pre>
		<p>と日記に書けばgoogleでtdiaryを検索するリンクになります
		(記述方法はスタイルによって変わります)。</p>
		HTML
	end
end
add_conf_proc( 'kw', kw_label ) do
	if @mode == 'saveconf' then
		kw_dic = []
		@cgi.params['kw.dic'][0].to_euc.each do |pair|
			k, u, s = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 3 )
			k = nil if k == ''
			s = nil if s != 'euc-jp' && s != 'sjis' && s != 'jis'
			kw_dic << [k, u, s] if u
		end
		@conf['kw.dic'] = kw_dic
	end
	@conf['kw.dic'] = {'google' => ['http://www.google.com/search?ie=euc-jp&amp;q=$1', 'euc-jp']} unless @conf['kw.dic']
	<<-HTML
	#{kw_desc}
	<p><textarea name="kw.dic" cols="70" rows="10">#{@conf['kw.dic'].collect{|a|a.join( " " )}.join( "\n" ) if @conf['kw.dic']}</textarea></p>
	HTML
end

