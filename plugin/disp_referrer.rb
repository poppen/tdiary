=begin
= 本日のリンク元もうちょっとだけ強化プラグイン((-$Id: disp_referrer.rb,v 1.36 2003-10-23 10:02:08 tadatadashi Exp $-))

== 概要
アンテナからのリンク、サーチエンジンの検索結果を、通常のリンク元の下にま
とめて表示します。サーチエンジンの検索結果は、検索語毎にまとめられます。

最新の日記の表示では、通常のリンク元以外のリンク元を隠します。

== Acknowledgements
This plugin uses
* Some of the search engine names and URLs
from disp_referrer.rb by MUTOH Masao.

Methods that parses URL is copied from cgi.rb distributed with Ruby and
edited.

The idea that categorize the URLs with [] delimited strings is from
kazuhiko.

The author of this plugin  appreciates them.

== Copyright notice
Copyright (C) 2003 zunda <zunda at freeshell.org>

Please note that some methods in this plugin are written by other
authors as written in the comments.

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

=begin ChangeLog
See ChangeLog for changes after this.

* Mon Sep 29, 2003 zunda <zunda at freeshell.org>
- forgot to change arguments after changing initialize()
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- name.untaint to eval name
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- use to_native instead of to_euc
* Mon Sep 19, 2003 zunda <zunda at freeshell.org>
- disp_referrer2.rb,v 1.1.2.104 commited as disp_referrer.rb
* Mon Sep  1, 2003 zunda <zunda at freeshell.org>
- more strcit check for infoseek search enigne
* Wed Aug 27, 2003 zunda <zunda at freeshell.org>
- rd.yahoo, Searchalot, Hotbot added
* Tue Aug 12, 2003 zunda <zunda at freeshell.org>
- search engine list cleaned up
* Mon Aug 11, 2003 zunda <zunda at freeshell.org>
- instance_eval for e[2] in the search engine list
* Wed Aug  7, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - キャッシュの更新をより確実にするようにしました。WWWブラウザから置換
    リストを作った場合にはリストの最初に追加されます。
  - secure=trueな日記でその他のリンク元リストが表示できるようになりました。
- Regexp generation for Wiki sites
* Wed Aug  6, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - 主なオプションとリンク元置換リストの効率的な編集がWWWブラウザからで
    きるようになりました。secure=trueな日記では一部の機能は使えません。
* Sat Aug  2, 2003 zunda <zunda at freeshell.org>
- Second version
- basic functions re-implemented
  - オプションを命名しなおしました。また不要なオプションを消しました。
    tdiary.confを編集していた方は、お手数ですが設定をしなおしてください。
  - Noraライブラリとキャッシュの利用で高速化しました。
  - 検索エンジンのリストをプラグインで持つようになりました。&や;を含む検
    索文字列も期待通りに抽出できます。
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- First version
=end

=begin
== このプラグインで定義されるクラスとメソッド
=== Array
Array#values_at()が無い場合、追加します。
=end
# 1.8 feature
unless [].respond_to?( 'values_at' ) then
	eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
		class Array
			alias values_at indices
		end
	MODIFY_CLASS
end

# to be visible from inside classes
Dispref2plugin = self
Dispref2plugin_cache_path = @cache_path
Dispref2plugin_secure = @conf.secure

# cache format
Root_DispRef2URL = 'dispref2url' # root for DispRef2URLs

=begin
=== Tdiary::Plugin::DispRef2DummyPStore
PStoreと同じメソッドを提供しますがなにもしません。db[key]は全てnilを返す
ことに注意してください。
=end
# dummy PStore
class DispRef2DummyPStore
	def initialize( file )
	end
	def transaction( read_only = false )
		yield
	end
	def method_missing( name, *args )
		nil
	end
end

=begin
=== Tdiary::Plugin::DispRef2PStore
@secure=falseな日記ではPStoreと同等のメソッドを、@secure=trueな日記では
何もしないメソッドを提供します。

--- DispRef2PSTore#transaction( read_only = false )
     Ruby-1.7以降の場合は読み込み専用に開くこともできます。Ruby-1.6の場
     合はread_only = trueでも読み書き用に開きます。

--- DispRef2PSTore#real?
      本物のPSToreが使える時はtrue、そうでない時はfalseを返します。
=end
unless @conf and @conf.secure then
	require 'pstore'
	class DispRef2PStore < PStore
		def real?
			true
		end
		def transaction( read_only = false )
			begin
				super
			rescue ArgumentError
				super()
			end
		end
	end
else
	class DispRef2PStore < DispRef2DummyPStore
		def real?
			false
		end
	end
end

=begin
=== Tdiary::Plugin::DispRef2String
文字コードの変換、URL、HTMLでの取り扱いに関するメソッド群です。インスタ
ンスは作りません。UconvライブラリやNoraライブラリがあればそれを使い、無
ければ無いなりに処理します。

--- DispRef2String::nora?
      Noraが使える時にはtrue、そうでないときにはfalseを返します。

--- DispRef2String::normalize( str )
      続く空白を取り去ったりsite:...という文字列を消したりして、検索キー
      ワードを規格化します。

--- DispRef2String::parse_query( str )
      URLに含まれるquery部(key=value&...)を解析し、結果をkeyをキー、
      valueの配列を値としたハッシュとして返します。値のアンエスケープは
      しません。valueが無かった場合は空文字列が設定されます。

--- DispRef2String::separate_query( str )
      URLをquery部より前と後に分けて配列として返します。query部が無い場
      合はnilを返します。

--- DispRef2String::hostname( str )
      URLに含まれるホスト名あるいはIPアドレスを返します。ホスト名がみつ
      からない場合は、((|str|))を返します。

--- DispRef2String::company_name( str, hash_list )
      URLより、googleやbiglobeといった名前のうち((|hash_list|))のkeyに含
      まれるものを返します。みつからない場合は、nilを返します。

--- DispRef2String::escapeHTML( str )
      HTMLに含まれても安全なようにエスケープします。

--- DispRef2String::unescape( str )
      URLをアンエスケープします。

--- DispRef2String::bytes( size )
      バイト単位の大きさをMB KB Bの適切な単位に変換します。

--- DispRef2String::comma( integer )
      数字をカンマで3桁ずつに分けます。

--- DispRef2String::url_regexp( url )
      ((|url|))から置換リスト用の正規表現文字列をつくります。

--- DispRef2String::url_match?( url, list )
      ((|url|))が((|list|))のどれかにマッチするかどうか調べます。

=end
# string handling
class DispRef2String

	# strips site:... portion (google), multiple spaces, and start/end spaces
	def self::normalize( str )
		str.sub( /\bsite:(\w+\.)*\w+\b/, '' ).gsub( /[　\s\n]+/, ' ' ).strip
	end

	# parse_query parses the not unescaped query in a URL
	# copied from from CGI::parse in cgi.rb by
	#   Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
	#   Copyright (C) 2000  Information-technology Promotion Agency, Japan
	#   Wakou Aoyama <wakou@ruby-lang.org>
	# eand edited
	def self::parse_query( str )
		params = Hash.new
		str.split( /[&;]/n ).each do |pair|
			k, v = pair.split( '=', 2 )
			( params[k] ||= Array.new ) << ( v ? v : '' )
		end
		params
	end

	# separate the query part (or nil) from a URL
	def self::separate_query( str )
		base, query = str.split( /\?/, 2 )
		if query then
			[ base, query ]
		else
			[ base, nil ]
		end
	end

	# get the host name (or nil) from a URL
	@@hostname_match = %r!https?://([^/]+)/?!
	def self::hostname( str )
		@@hostname_match =~ str ? $1 : str
	end

	# get the `company name' included in keys of hash_table (or nil) from a URL
	def self::company_name( str, hash_table )
		hostname( str ).split( /\./ ).values_at( -2, -3, 0 ).each do |s|
			return s if s and hash_table.has_key?( s.downcase )
		end
		nil
	end

	# escapeHTML: escape to be used in HTML
	# unescape: unesape the URL
	@@have_nora = false
	begin
		begin
			require 'web/escape'
			@@have_nora = true
		rescue LoadError
			require 'escape'
			@@have_nora = true
		end
		def self::escapeHTML( str )
			Web::escapeHTML( str )
		end
		def self::unescape( str )
			Web::unescape( str )
		end
	rescue LoadError
		def self::escapeHTML( str )
			# escape ruby 1.6 bug.
			str.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
				'%' + $1.unpack('H2' * $1.size).join('%').upcase
			end.gsub(/ /, '+')
		end
		def self::unescape( str )
			# escape ruby 1.6 bug.
			str.gsub( /\+/, ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
				[$1.delete('%')].pack('H*')
			end
		end
	end

	# Nora?
	def self::nora?
		@@have_nora
	end

	# add K, M with 1024 divisions
	def self::bytes( size )
		s = size.to_f
		t = s / 1024.0
		return( '%.0f' % s ) if t < 1
		s = t
		t = s / 1024.0
		return( '%.1f K' % s ) if t < 1
		return( '%.1f M' % t )
	end

	# insert comma
	def self::comma( integer )
		integer.to_s.reverse.scan(/.{1,3}/).join(',').reverse
		# [ruby-list:30144]
	end

	# make up a regexp from a url
	def self::url_regexp( url )
		r = url.dup
		r.sub!( /\/\d{4,8}\.html$/, '/' )	# from a tDiary?
		r.sub!( /\/(index\.(rb|cgi))?\?date=\d{4,8}$/, '/' )	# from a tDiary?
		r.gsub!( /\./, '\\.' )	# dots in the FQDN
		unless /(w|h)iki/i =~ r then
			r.sub!( /\?.*/, '.*' )
		else
			r.sub!( /\?.*/, '\?(.*)' )
		end
		r.sub!( /\/(index\.html?)$/, '/' )	# directory index
		r.sub!( /\/$/, '/?.*' )	# may be also from a lower level
		"^#{r}"	# always good to put a ^
	end

	# matchs to the regexp strings?
	def self::url_match?( url, list )
		list = list.split( /\n/ ) if String == list.class
		list.each do |entry|
			entry = entry[0] if Array == entry.class
			return true if /#{entry}/i =~ url
		end
		false
	end

end

=begin
=== Tdiary::Plugin::DispRef2Setup
プラグインの動作を決めるパラメータを設定します。

--- DispRef2Setup::Last_parenthesis
      文字列の最後の()の中身が$1に設定される正規表現です。

--- DispRef2Setup::First_bracket
      文字列の最初の[]の中身が$1に、その後の文字列が$2に設定される正規表
      現です。

--- DispRef2Setup::Defaults
      オプションのデフォルト値です。tDiary本体から@optionsで設定するには、
      このハッシュのkeyの前に「disp_referrer2.」をつけたkeyを使ってくだ
      さい。オプションの詳細はソースのコメントを参照してください。

--- DispRef2Setup::new( conf, limit = 100, is_long = true )
      ((|conf|))にはtDiaryの@confを、((|limit|))には一項目あたりの表示リ
      ンク元数を、((|is_long|))は一日分の表示の場合にはtrueを、最新の表
      示の場合にはfalseを設定してください。

--- DispRef2Setup#update!
      tDiaryの@optionsにより自身を更新します。

--- DispRef2Setup#is_long
--- DispRef2Setup#referer_table
--- DispRef2Setup#no_referer
--- DispRef2Setup#secure
      それぞれ、一日分の表示かどうか、tDiaryの置換テーブル、tDiaryのリン
      ク元除外リスト、日記のセキュリティ設定を返します。

--- DIspRef2Setup#to_native( str )
      tDiaryの言語リソースで定義されている文字コードを正規化するメソッド
      です。

--- DispRef2Setup#[]
      設定されている値を返します。
=end
# configuration of this plugin
class DispRef2Setup < Hash
	# useful regexps
	Last_parenthesis = /\((.*?)\)\Z/m
	First_bracket = /\A\[(.*?)\](.+)/m

	# default options
	Defaults = {
		'long.only_normal' => false,
			# trueの場合、一日分の表示で、通常のリンク元以外を隠します。
		'short.only_normal' => true,
			# trueの場合、最新の表示で、通常のリンク元以外を隠します。
			# falseの場合は、プラグインの無い場合と全くおなじ表示になります。
		'antenna.url' => '(\/a\/|(?!.*\/diary\/)antenna[\/\.]|\/tama\/|www\.tdiary\.net\/?(i\/)?(\?|$)|links?|kitaj\.no-ip\.com\/iraira\/)',
			# アンテナのURLに一致する正規表現の文字列です。
		'antenna.title' => '(アンテナ|links?|あんてな)',
			# アンテナの置換後の文字列に一致する正規表現の文字列です。
		'normal.label' => Dispref2plugin.referer_today,
			# 通常のリンク元のタイトルです。デフォルトでは、「本日のリンク元」です。
		'antenna.label' => Disp_referrer2_antenna_label,
			# アンテナのリンク元のタイトルです。
		'unknown.label' => Disp_referrer2_unknown_label,
			# その他のリンク元のタイトルです。
		'unknown.hide' => false,
			# trueの場合はリンク元置換リストにないURLは表示しません
		'search.label' => Disp_referrer2_search_label,
			# 検索エンジンからのリンク元のタイトルです。
		'unknown.divide' => true,
			# trueの場合、置換リストに無いURLを通常のリンク元と分けて表示します。
			# falseの場合、置換リストに無いURLを通常のリンク元と混ぜて表示します。
		'normal.group' => true,
			# trueの場合、置換後の文字列で通常のリンク元をグループします。
			# falseの場合、URL毎に別のリンク元として表示します。
		'normal.categorize' => true,
			# trueの場合、置換後の文字列の最初の[]の文字列でカテゴリー分けします。
		'normal.ignore_parenthesis' => true,
			# trueの場合、グループする際に置換後の文字列の最後の()を無視します。
		'antenna.group' => true,
			# trueの場合、置換後の文字列で通常のリンク元をグループします。
			# falseの場合、URL毎に別のリンク元として表示します。
		'antenna.ignore_parenthesis' => true,
			# trueの場合、グループする際に置換後の文字列の最後の()を無視します。
		'search.expand' => false,
			# trueの場合、検索キーワードとともに検索エンジン名を表示します。
			# falseの場合、回数のみを表示します。
		'search.unknown_keyword' => Disp_referrer2_search_unknown_keyword,
			# キーワードがわからない検索エンジンからのリンクに使う文字列です。
		'search_engines' => DispReferrer2_Engines,
			# 検索エンジンのハッシュです。
		'cache_label' => Disp_referrer2_cache_label,
			# 検索エンジンのキャッシュのURLを表示する文字列です。
		'cache_path' => "#{Dispref2plugin_cache_path}/disp_referrer2.cache",
			# このプラグインで使うキャッシュファイルのパスです。
		'no_cache' => false,
			# trueの場合、@secure=falseな日記でもキャッシュを使いません。
		'normal-unknown.title' => '\Ahttps?:\/\/',
			# 置換された「その他」のリンク元のタイトル、あるいは置換されていな
			# いリンク元のタイトルにマッチします。
		'configure.use_link' => true,
			# リンク元置換リストの編集画面で、リンク元へのリンクを作ります。
		'reflist.ignore_urls' => '',
			# 置換リストのリストアップの際に無視するURLの正規表現の文字列
			# \n区切で並べます
	}

	attr_reader :is_long, :referer_table, :no_referer, :secure

	def initialize( conf, limit = 100, is_long = true )
		super()
		@conf = conf

		# mode
		@is_long = is_long
		@limit = limit
		@options = conf.options

		# URL tables
		@referer_table = conf.referer_table
		@no_referer = conf.no_referer

		# security
		@secure = Dispref2plugin_secure

		# options from tDiary
		update!
	end

	def to_native( str )
		@conf.to_native( str )
	end

	# options from tDiary
	def update!
		# defaults
		self.replace( DispRef2Setup::Defaults.dup )

		# from tDiary
		self.each_key do |key|
			options_key = "disp_referrer2.#{key}"
			self[key] = @options[options_key] if @options.has_key?( options_key )
		end

		# additions
		self['labels'] = {
			DispRef2URL::Normal => self['normal.label'],
			DispRef2URL::Antenna => self['antenna.label'],
			DispRef2URL::Search => self['search.label'],
			DispRef2URL::Unknown => self['unknown.label'],
		}
		self['antenna.url.regexp'] = /#{self['antenna.url']}/i
		self['antenna.title.regexp'] = /#{self['antenna.title']}/i
		self['normal-unknown.title.regexp'] = /#{self['normal-unknown.title']}/i

		# limits
		self['limit'] = Hash.new
		self['limit'][DispRef2URL::Normal] = @limit || 0
		if ( @is_long ? self['long.only_normal'] : self['short.only_normal'] ) then
			[DispRef2URL::Antenna, DispRef2URL::Search, DispRef2URL::Unknown].each do
				|c| self['limit'][c] = 0
			end
		else
			[DispRef2URL::Antenna, DispRef2URL::Search, DispRef2URL::Unknown].each do |c|
				self['limit'][c] = @limit || 0
			end
		end
		if self['unknown.hide'] then
			self['limit'][DispRef2URL::Unknown] = 0
		end
		self
	end

end

=begin
=== Tdiary::Plugin::DispRef2URL

--- DispRef2URL::new( unescaped_url, setup = nil )
      素のURLを元にしてインスタンスを生成します。((|setup|))がnilではない
      場合には、parse( ((|setup|)) ) もします。

--- DispRef2URL#restore( db )
      キャッシュから自分のURLに対応する情報を取り出します。((|db|))は
      DispRef2PStoreのインスタンスです。キャッシュされていなかった場合
      にはnilを返します。

--- DispRef2URL#parse( setup )
      DispRef2Setupのインスタンス((|setup|))にしたがって、自分を解析します。

--- DispRef2URL::Cached_options
      DispRef2Setupで設定されるオプションのうち、キャッシュに影響を与え
      るものの配列を返します。

--- DispRef2URL#store( db )
      キャッシュに自分を記録します。((|db|))はDispRef2PStoreのインスタ
      ンスです。記録に成功した場合は自分を、そうでない場合にはnilを返し
      ます。

--- DispRef2URL#==( other )
      解析結果が等しい場合に真を返します。

--- DispRef2URL#url
--- DispRef2URL#category
--- DispRef2URL#category_label
--- DispRef2URL#title
--- DispRef2URL#title_ignored
--- DispRef2URL#title_group
--- DispRef2URL#key
      それぞれ、URL、カテゴリー、カテゴリー名(ユーザーが設定しなければnil)、
      タイトル、グループ化した時に無視されたタイトル(無ければnil)、グル
      ープ化した後のタイトル、グループ化する際のキーを返します。parseあ
      るいはrestoreしないと設定されません。

=end
# handling of a URL
class DispRef2URL
	attr_reader :url, :category, :category_label, :title, :title_ignored, :title_group, :key

	# category numbers
	Normal = :normal
	Antenna = :antenna
	Search = :search
	Unknown = :unknown
	Categories = [Normal, Antenna, Search, Unknown]

	# options which affects the cache
	Cached_options = %w(
		search_engines
		cache_label
		unknown.divide
		antenna.url.regexp
		antenna.url
		antenna.title.regexp
		antenna.title
		antenna.group
		antenna.ignore_parenthesis
		normal.categorize
		normal.group
		normal.ignore_parenthesis
		cache_path
	)

	def initialize( unescaped_url, setup = nil )
		@url = unescaped_url
		@dbcopy = nil
		parse( setup ) if setup
	end

	def restore( db )
		if db.real? and (
			begin
				db[Root_DispRef2URL]
			rescue PStore::Error
				false
			end
		) and db[Root_DispRef2URL][@url] then
			@category, @category_label, @title, @title_ignored, @title_group, @key = db[Root_DispRef2URL][@url]
			self
		else
			nil
		end
	end

	def parse( setup )
		parse_as_search( setup ) || parse_as_others( setup )
		self
	end

	def store( db )
	 if db.real? and (
			begin
				db[Root_DispRef2URL] ||= Hash.new
			rescue PStore::Error
				db[Root_DispRef2URL] = Hash.new
			end
		) then
			 unless @category == DispRef2URL::Search then
				db[Root_DispRef2URL]["#{@url}"] = [ @category, @category_label, @title, @title_ignored, @title_group, @key ]
			else
				db[Root_DispRef2URL].delete( @url )
			end
			self
		else
			nil
		end
	end

	def ==(other)
		return @url == other.url &&
			@category == other.category &&
			@category_label == other.category_label &&
			@title == other.title &&
			@title_ignored == other.title_ignored &&
			@title_group == other.title_group &&
			@key == other.key
	end

	private
		def parse_as_search( setup )
			# see which search engine is used
			engine = DispRef2String::company_name( @url, setup['search_engines'] )
			return nil unless engine

			# url and query
			urlbase, query = DispRef2String::separate_query( @url )

			# get titles and keywords
			title = nil
			keyword = nil
			cached_url = nil
			values = query ? DispRef2String::parse_query( query ) : nil
			catch( :done ) do
				setup['search_engines'][engine].each do |e|
					if( e[0] =~ urlbase ) then
						title = eval( e[1] )
						if e[2].empty? then
							keyword = setup['search.unknown_keyword']
							throw :done
						end
						if String == e[2].class then
							k, c = (query ? query : @url ).instance_eval( e[2] )
							if k then
								keyword = k
							else
								keyword = setup['search.unknown_keyword']
							end
							cached_url = c ? c : nil
							throw :done
						else	# should be an Array usually
							if not values then
								keyword = setup['search.unknown_keyword']
								throw :done
							end
							e[2].each do |k|
								if( values[k] and not values[k][0].empty? ) then
									unless( e[3] and e[3] =~ values[k][0] ) then
										cached_url = nil
										keyword = values[k][0]
										throw :done
									else
										cached_url = $1
										keyword = $` + $'
										throw :done
									end
								end
							end
						end
					end
				end
			end
			return nil unless keyword

			# format
			@category = Search
			@category_label = nil
			@title = DispRef2String::normalize( setup.to_native( DispRef2String::unescape( keyword ) ) )
			@title_ignored = setup.to_native( title )
			@title_ignored << sprintf( setup['cache_label'], setup.to_native( DispRef2String::unescape( cached_url ) ) ) if cached_url
			@title_group = @title
			@key = @title_group

			self
		end

		def parse_as_others( setup )

			# try to convert with referer_table
			matched = false
			title = setup.to_native( DispRef2String::unescape( @url ) )
			setup.referer_table.each do |url, name|
				unless /\$\d/ =~ name then
					if title.gsub!( /#{url}/i, name ) then
						matched = true
						break
					end
				else
					name.untaint unless setup.secure
					if title.gsub!( /#{url}/i ) { eval name } then
						matched = true
						break
					end
				end
			end

			if setup['antenna.url.regexp'] =~ @url or setup['antenna.title.regexp'] =~ title then
			# antenna
				@category = Antenna
				@category_label = nil
				grouping = setup['antenna.group']
				ignoring = setup['antenna.ignore_parenthesis']
			elsif matched and not setup['normal-unknown.title.regexp'] =~ title then
			# normal
				@category = Normal
				if setup['normal.categorize'] and DispRef2Setup::First_bracket =~ title then
					@category_label = $1
					title = $2
				else
					@category_label = nil
				end
				grouping = setup['normal.group']
				ignoring = setup['normal.ignore_parenthesis']
			else
			# unknown
				@title = title
				@title_ignored = nil
				@title_group = title
				@key = @url
				if setup['unknown.divide'] then
					@category = Unknown
					@category_label = nil
				else
					@category = Normal
					@category_label = nil
				end
				return self
			end

			# format the title
			if not grouping then
				@title  = title
				@title_group = title
				@title_ignored = nil
				@key = url
			elsif not ignoring then
				@title = title
				@title_group = title
				@title_ignored = nil
				@key = title_group
			else
				@title = title
				@title_group = title.gsub( DispRef2Setup::Last_parenthesis, '' )
				@title_ignored = $1
				@key = title_group
			end

			self
		end

	# private
end

=begin
=== Tdiary::Plugin::DispRef2Refs
--- DispRef2Refs::new( diary, setup )
      日記((|diary|))のリンク元を、DispRef2Setupのインスタンス((|setup|))
      にしたがって解析します。

--- DispRef2Refs#special_categories
      置換文字列の最初に[]でかこったカテゴリ名ラベルを挿入することによっ
      てユーザーによって定義されたカテゴリーの配列を返します。

--- DispRef2Refs#urls( category = nil )
      リンク元のうち、カテゴリーが((|category|))に一致するものを、
      DispRef2Cache#urlsと同様のフォーマットで返します。((|category|))
      がnilの場合は全てのURLの情報を返します。

--- DispRef2Refs#to_long_html
--- DispRef2Refs#to_short_html
      リンク元のリストをHTML断片にします。

=end
class DispRef2Refs
	def initialize( diary, setup )
		@setup = setup
		@refs = Hash.new
		@has_ref = false
		return unless diary

		done_flag = Hash.new
		DispRef2URL::Categories.each do |c|
			done_flag[c] = (@setup['limit'][c] < 1)
		end

		db = @setup['no_cache'] ? DispRef2DummyPStore.new( @setup['cache_path'] ) : DispRef2PStore.new( @setup['cache_path'] )

		h = Hash.new
		db.transaction do
			diary.each_referer( diary.count_referers ) do |count, url|
				ref = DispRef2URL.new( url )
				@has_ref = true
				unless ref.restore( db ) then
					ref.parse( @setup )
					ref.store( db )
				end
				if @setup.is_long and @setup['normal.categorize'] then
					cat_key = ref.category_label || ref.category
				else
					cat_key = ref.category
				end
				next if done_flag[cat_key]
				h[cat_key] ||= Hash.new
				unless h[cat_key][ref.key] then
					h[cat_key][ref.key] = [count, ref.title_group, [[count, ref]]]
				else
					h[cat_key][ref.key][0] += count
					h[cat_key][ref.key][2] << [count, ref] if h[cat_key][ref.key].size < @setup['limit'][ref.category]
				end
				if h[cat_key].size >= @setup['limit'][ref.category] then
					done_flag[ref.category] = true
					break unless done_flag.has_value?( false )
				end
			end
		end
		db = nil

		h.each_pair do |cat_key, hash|
			@refs[cat_key] = hash.values
			@refs[cat_key].sort! { |a, b| b[0] <=> a[0] }
		end
	end

	def special_categories
		@refs.keys.reject!{ |c| DispRef2URL::Categories.include?( c ) }
	end

	# urls in the diary as a hash
	def urls( category = nil )
		h = Hash.new
		category = [ category ] unless category.class == Array
		(category ? category : @refs.keys).each do |cat|
			next unless @refs[cat]
			@refs[cat].each do |a|
				a[2].each do |b|
					h[b[1].url] = [ b[1].category, b[1].category_label, b[1].title, b[1].title_ignored, b[1].title_group, b[1].key ]
				end
			end
		end
		h
	end

	def to_short_html
		return '' if not @refs[DispRef2URL::Normal] or @refs[DispRef2URL::Normal].size < 1
		result = %Q[#{@setup['labels'][DispRef2URL::Normal]} | ]
		@refs[DispRef2URL::Normal].each do |a|
			result << %Q[<a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}" title="#{DispRef2String::escapeHTML( a[2][0][1].title )}">#{a[0]}</a> | ]
		end
		result
	end

	def to_long_html
		return '' if not @has_ref
		# we always need a caption
		result = %Q[<div class="caption">#{@setup['labels'][DispRef2URL::Normal]}</div>\n]
		result << others_to_long_html( DispRef2URL::Normal )
		if( @setup['normal.categorize'] and special_categories ) then
			special_categories.each do |cat|
				result << others_to_long_html( cat )
			end
		end
		result << others_to_long_html( DispRef2URL::Antenna )
		result << others_to_long_html( DispRef2URL::Unknown )
		result << search_to_long_html
		result
	end

	private
		def others_to_long_html( cat_key )
			return '' unless @refs[cat_key] and @refs[cat_key].size > 0
			result = ''
			unless DispRef2URL::Normal == cat_key then
				# to_long_html provides the catpion for normal links
				if @setup['labels'].has_key?( cat_key ) then
					result << %Q[<div class="caption">#{@setup['labels'][cat_key]}</div>\n]
				else
					result << %Q[<div class="caption">#{cat_key}</div>\n]
				end
			end
			result << '<ul>'
			@refs[cat_key].each do |a|
				if a[2].size == 1 then
					result << %Q[<li><a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[2][0][1].title )}</a> &times;#{a[0]}</li>\n]
				elsif not a[2][0][1].title_ignored then
					result << %Q[<li><a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[1] )}</a> &times;#{a[0]} : #{a[2][0][0]}]
					a[2][1..-1].each do |b|
						title = (b[1].title != a[1]) ? %Q[ title="#{DispRef2String::escapeHTML( b[1].title )}"] : ''
						result << %Q[, <a href="#{DispRef2String::escapeHTML( b[1].url )}"#{title}>#{b[0]}</a>]
					end
					result << "</li>\n"
				else
					result << %Q[<li>#{DispRef2String::escapeHTML( a[1] )} &times;#{a[0]} : ]
					comma = nil
					a[2][0..-1].each do |b|
						title = (b[1].title != a[1]) ? %Q[ title="#{DispRef2String::escapeHTML( b[1].title )}"] : ''
						result << comma if comma
						result << %Q[<a href="#{DispRef2String::escapeHTML( b[1].url )}"#{title}>#{b[0]}</a>]
						comma = ', '
					end
					result << "</li>\n"
				end
			end
			result << "</ul>\n"
		end

		def search_to_long_html
			return '' unless @refs[DispRef2URL::Search] and @refs[DispRef2URL::Search].size > 0
			result = %Q[<div class="caption">#{@setup['labels'][DispRef2URL::Search]}</div>\n]
			result << ( @setup['search.expand'] ? "<ul>\n" : '<ul><li>' )
			sep = nil
			@refs[DispRef2URL::Search].each do |a|
				result << sep if sep
				if @setup['search.expand'] then
					result << '<li>'
					result << DispRef2String::escapeHTML( a[1] )
				else
					result << %Q[<a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[1] )}</a>]
				end
				result << %Q[ &times;#{a[0]} ]
				if @setup['search.expand'] then
					result << ' : '
					if a[2].size < 2 then
						result << %Q[<a href="#{DispRef2String::escapeHTML( a[2][0][1].url )}">#{DispRef2String::escapeHTML( a[2][0][1].title_ignored )}</a>]
					else
						comma = nil
						a[2].each do |b|
							result << comma if comma
							result << %Q[<a href="#{DispRef2String::escapeHTML( b[1].url )}">#{DispRef2String::escapeHTML( b[1].title_ignored )}</a> &times;#{b[0]}]
							comma = ', ' unless comma
						end
					end
				end
				result << '</li>' if @setup['search.expand']
				sep = ( @setup['search.expand'] ? "\n" : ' / ' ) unless sep
			end
			result << ( @setup['search.expand'] ? "</ul>\n" : "</li></ul>\n" )
		end

	# private
end

=begin
=== Tdiary::Plugin::DispRef2Cache
キャッシュの管理をするクラスです。

--- DispRef2Cache.new( setup )
      リンク元のキャッシュを、DispRef2Setupのインスタンス((|setup|))にした
      がって管理します。

--- DispRef2Cache#update
      キャッシュの内容を現在の設定に従って更新します。更新されたURLの数
      を返します。

--- DispRef2Cache#size
      キャッシュファイルの大きさをバイト単位で返します。

--- DispRef2Cache#entries
      キャッシュされているURLの数を返します。

--- DispRef2Cache#urls( category = nil )
      キャッシュされているURLの情報のうち、カテゴリーが((|category|))に
      一致するものを、URLをキー、下記の配列を値としたハッシュとして返し
      ます。((|category|))がnilの場合は全てのURLの情報を返します。
      * カテゴリー
      * カテゴリーのラベル(あるいはnil)
      * 置換後の文字列
      * グループする際に無視された文字列
      * グループ全体の文字列
      * グループする際のキー

--- DispRef2Cache#unknown_urls
      キャッシュされているURLのうち、置換できなかったもののURLの配列を 
      返します。置換できなかったURLが無い場合には空の配列を返します。

=end
# cache management
class DispRef2Cache
	def initialize( setup )
		@setup = setup
	end

	# updates the cache according to the current setup
	def update
		return 0 if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		h = Hash.new
		r = 0
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction do
			begin
				db[Root_DispRef2URL].each_key do |url|
					ref = DispRef2URL::new( url )
					t = ref.restore( db )
					orig = t ? t.dup : nil
					new = ref.parse( @setup )
					if orig != new then
						r += 1
						ref.store( db )
					end
				end
			rescue PStore::Error
			end
		end
		db = nil
		r
	end

	# size of cache in bytes
	def size
		return 0 if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		FileTest.size( @setup['cache_path'] )
	end

	# number of urls in the cache
	def entries
		return 0 if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		r = 0
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction( true ) do
			begin
				r = db[Root_DispRef2URL].size
			rescue PStore::Error
				r = 0
			end
		end
		db = nil
		r
	end

	# cached urls as a hash
	def urls( category = nil )
		return {} if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		h = Hash.new
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction( true ) do
			begin
				db[Root_DispRef2URL].each_pair do |url, data|
					h[url] = data if not category or category == data[0]
				end
			rescue PStore::Error
			end
		end
		db = nil
		h
	end

	# cached unknown urls as an array
	def unknown_urls
		return [] if @setup.secure or @setup['no_cache'] or not FileTest::exist?( @setup['cache_path'] )

		r = Array.new
		db = DispRef2PStore.new( @setup['cache_path'] )
		db.transaction( true ) do
			begin
				db[Root_DispRef2URL].each_pair do |url, data|
					next if DispRef2String::url_match?( url, @setup.no_referer )
					next if DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] )
					r << url if DispRef2URL::Unknown == data[0] or @setup['normal-unknown.title.regexp'] =~ data[2]
				end
			rescue PStore::Error
			end
		end
		db = nil
		r
	end

end

=begin
=== TDiary::Plugin::DispRef2SetupIF
このプラグインの設定のためのHTMLを生成し、CGIリクエストを受け取ります。

--- DispRef2SetupIF::new( cgi, setup, conf, mode )
      CGIのインスタンス((|cgi|))とDispRef2Setupのインスタンス((|setup|))
      より、設定のためのインスタンスを生成します。TDiary::Pluginより、
      @confと@modeも引数に指定してください。

--- DispRef2SetupIF#show_html
      設定の更新と必要ならキャッシュの更新をしてからHTMLを表示します。

--- DispRef2SetupIF#show_description
      このプラグインのHTML版の説明です。設定する項目も選べます。

--- DispRef2SetupIF#show_options
      このプラグインのオプションを設定するHTML断片を返します。

--- DispRef2SetupIF#show_unknown_list
      リンク元置換リストの編集のためのHTML断片を返します。

--- DispRef2SetupIF#update_options
      cgiからの入力に応じて、このプラグインのオプションを更新します。
      @setupも更新します。

--- DispRef2SetupIF#update_tables
      cgiからの入力に応じて、リンク元置換リストを更新します。
=end
# WWW Setup interface
class DispRef2SetupIF

	# setup mode
	Options = 'options'
	RefList = 'reflist'
	
	def initialize( cgi, setup, conf, mode )
		@cgi = cgi
		@setup = setup
		@conf = conf
		@conf['disp_referrer2.reflist.ignore_urls'] ||= ''
		@mode = mode
		@updated_url = nil
		@need_cache_update = false
		if @cgi.params['dr2.change_mode'] and @cgi.params['dr2.change_mode'][0] then
			case @cgi.params['dr2.new_mode'][0]
			when Options
				@current_mode = Options
			when RefList
				@current_mode = RefList
			else
				@current_mode = Options
			end
		elsif @cgi.params['dr2.current_mode'] then
			case @cgi.params['dr2.current_mode'][0]
			when Options
				@current_mode = Options
			when RefList
				@current_mode = RefList
			else
				@current_mode = Options
			end
		else
			@current_mode = Options
		end
		if not @setup.secure and not @setup['no_cache'] then
			@cache = DispRef2Cache.new( @setup )
		else
			@cache = nil
		end
	end

	# do what to do and make html
	def show_html
		# things to be done
		if @mode == 'saveconf' then
			case @current_mode
			when Options
				update_options
			when RefList
				update_tables
			end
		end

		# update cache
		if not @setup.secure then
			if not @setup['no_cache'] then
				unless @cache then
					@need_cache_update = true
					@cache = DispRef2Cache.new( @setup )
				end
				if not 'never' == @cgi.params['dr2.cache.update'][0] and ('force' == @cgi.params['dr2.cache.update'][0] or @need_cache_update) then
					@updated_url = @cache.update
				end
			else
				if @setup['no_cache'] then
					@cache = nil
				end
			end
		end

		# result
		r = show_description
		case @current_mode
		when Options
			r << show_options
		when RefList
			r << show_unknown_list
		end
		r
	end

	# show description
	def show_description
		r = Disp_referrer2_abstract.dup
		if DispRef2String.nora? then
			r << Disp_referrer2_with_Nora
		else
			r << Disp_referrer2_without_Nora
		end
		if @cache then
			r << sprintf( Disp_referrer2_updated_urls, @updated_url ) if @updated_url
			r << sprintf( Disp_referrer2_cache_info, DispRef2String::bytes( @cache.size ), DispRef2String::comma( @cache.entries ) )
			r << sprintf( Disp_referrer2_update_info, "#{@conf.update}?conf=referer", "#{@conf.update}?conf=disp_referrer2;dr2.cache.update=force;dr2.current_mode=#{@current_mode}" )
		end
		r << "<p>\n"
		case @current_mode
		when Options
			r << sprintf( Disp_referrer2_move_to_refererlist, "#{@conf.update}?conf=disp_referrer2;dr2.new_mode=#{RefList};dr2.change_mode=true" )
		when RefList
			r << sprintf( Disp_referrer2_move_to_config, "#{@conf.update}?conf=disp_referrer2;dr2.new_mode=#{Options};dr2.change_mode=true" )
		end
		r << sprintf( Disp_referrer2_also_todayslink, "#{@conf.update}?conf=referer" )
		r << %Q{<input type="hidden" name="saveconf" value="ok"></p><hr>\n}
		r
	end

	# updates the options
	def update_options
		dirty = false
		# T/F options
		%w( antenna.group antenna.ignore_parenthesis antenna.search.expand
			normal.categorize normal.group normal.ignore_parenthesis
			search.expand long.only_normal short.only_normal no_cache unknown.divide
			unknown.hide
		).each do |key|
			tdiarykey = 'disp_referrer2.' + key
			case @cgi.params['dr2.' + key][0]
			when 'true'
				unless @conf[tdiarykey] == true then
					@conf[tdiarykey] = true
					@need_cache_update = true if DispRef2URL::Cached_options.include?( key )
					dirty = true
				end
			when 'false'
				unless @conf[tdiarykey] == false then
					@conf[tdiarykey] = false
					@need_cache_update = true if DispRef2URL::Cached_options.include?( key )
					dirty = true
				end
			end
		end

		# update @setup
		@setup.update! if dirty
	end

	# referer tables
	def update_tables
		dirty = false

		if @cgi.params['dr2.urls'] and @cgi.params['dr2.urls'][0].to_i > 0
			@cgi.params['dr2.urls'][0].to_i.times do |i|
				if not @cgi.params["dr2.#{i}.reg"][0].empty? and not @cgi.params["dr2.#{i}.title"][0].empty? then
					a = [
						@setup.to_native( @cgi.params["dr2.#{i}.reg"][0] ).sub( /[\r\n]+/, '' ),
						@setup.to_native( @cgi.params["dr2.#{i}.title"][0] ).sub( /[\r\n]+/, '' )
					]
					if not a[0].empty? and not a[1].empty? then
						@conf.referer_table2.unshift( a )
						@conf.referer_table.unshift( a )
							# to reflect the change in this requsest
						@need_cache_update = true
						dirty = true
					end
				end
				if 'true' == @cgi.params["dr2.#{i}.noref"][0] then
					unless @cgi.params["dr2.#{i}.reg"][0].empty? then
						reg = @setup.to_native( @cgi.params["dr2.#{i}.reg"][0] ).strip
						unless reg.empty? then
							@conf.no_referer2.unshift( reg )
							@conf.no_referer.unshift( reg	)
								# to reflect the change in this requsest
						end
					end
				end
				if 'true' == @cgi.params["dr2.#{i}.ignore"][0] then
					unless @cgi.params["dr2.#{i}.reg"][0].empty? then
						reg = @setup.to_native( @cgi.params["dr2.#{i}.reg"][0] ).strip
						unless reg.empty? then
							@conf['disp_referrer2.reflist.ignore_urls'] << reg + "\n"
							dirty = true
						end
					end
				end
			end
		end

		if @cgi.params['dr2.clear_ignore_urls'] and 'true' == @cgi.params['dr2.clear_ignore_urls'][0] then
			@conf['disp_referrer2.reflist.ignore_urls'] = ''
			dirty = true
		end

		%w( url title ).each do |cat|
			if 'true' == @cgi.params["dr2.antenna.#{cat}.default"][0]  then
				@conf["disp_referrer2.antenna.#{cat}"] = DispRef2Setup::Defaults["antenna.#{cat}"]
				dirty = true
				@need_cache_update = true
			elsif @cgi.params["dr2.antenna.#{cat}"] and @cgi.params["dr2.antenna.#{cat}"][0] and @cgi.params["dr2.antenna.#{cat}"][0] != @conf["disp_referrer2.antenna.#{cat}"] then
				newval = @cgi.params["dr2.antenna.#{cat}"][0].strip
				unless newval.empty? then
					@conf["disp_referrer2.antenna.#{cat}"] = newval
					dirty = true
					@need_cache_update = true
				end
			end
		end

		# update @setup
		@setup.update! if dirty
	end

end

=begin
=== TDiary::Plugin::DispRef2Latest
キャッシュが無い場合に、設定プラグインで不明のリンク元を得るためのクラス
です。

--- DispRef2Latest::new( cgi, skeltonfile, conf, setup )
      TDiary::TDiaryLatestの引数に加えて、DispRef2Setupのインスタンス
      ((|setup|))を引数にとります。

--- DispRef2Latest::unknown_urls
      最新の日記のリンク元のうち、置換できなかったもののURLの配列を返し
      ます。置換できなかったURLが無い場合には空の配列を返します。

=end
class DispRef2Latest < TDiary::TDiaryLatest

	def initialize( cgi, rhtml, conf, setup )
		super( cgi, rhtml, conf )
		@setup = setup
	end

	# correct unknown URLs from the newest diaries
	def unknown_urls
		r = Array.new
		self.latest( @conf.latest_limit ) do |diary|
			refs = DispRef2Refs.new( diary, @setup )
			h = refs.urls( DispRef2URL::Antenna )
			h.each_key do |url|
				next unless @setup['normal-unknown.title.regexp'] =~ h[url][2]
				next if DispRef2String::url_match?( url, @setup.no_referer )
				next if DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] )
				r << url
			end
			h = nil
			refs.urls( DispRef2URL::Unknown ).each_key do |url|
				next if DispRef2String::url_match?( url, @setup.no_referer )
				next if DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] )
				r << url
			end
		end
		r.uniq
	end

end

=begin
=== Tdiary::Plugin
--- Tdiary::Plugin#configure_disp_referrer2
      このプラグインの設定のために使われるメソッドです。add_conf_procさ
      れます。

以下は、このプラグインでオーバーライドされるtDiaryのメソッドです。
--- Tdiary::Plugin#referer_of_today_long( diary, limit = 100 )
--- Tdiary::Plugin#referer_of_today_short( diary, limit = 10 )
=end

# for configuration interface
add_conf_proc( 'disp_referrer2', Disp_referrer2_name ) do
	setup = DispRef2Setup.new( @conf, 100, true )
	wwwif = DispRef2SetupIF.new( @cgi, setup, @conf, @mode )
	wwwif.show_html
end

# for one-day diary
def referer_of_today_long( diary, limit = 100 )
	return '' if bot?
	setup = DispRef2Setup.new( @conf, limit, true )
	DispRef2Refs.new( diary, setup ).to_long_html
end

# for newest diary
alias dispref2_original_referer_of_today_short referer_of_today_short
def referer_of_today_short( diary, limit = 10 )
	return '' if bot?
	return dispref2_original_referer_of_today_short( diary, limit ) if @options.has_key?( 'disp_referrer2.short.only_normal' ) and not @options['disp_referrer2.short.only_normal']
	setup = DispRef2Setup.new( @conf, limit, false )
	DispRef2Refs.new( diary, setup ).to_short_html
end

# we have to know the unknown urls at this moment in a secure diary
if @conf.secure and (\
	( @cgi.params['dr2.change_mode'] \
		and DispRef2SetupIF::RefList == @cgi.params['dr2.new_mode'][0] ) \
		or ( @cgi.params['dr2.current_mode'] \
		and DispRef2SetupIF::RefList == @cgi.params['dr2.current_mode'][0] ) )
then
	setup = DispRef2Setup.new( @conf, 100, true )
	DispRef2Latest_cache = DispRef2Latest.new( @cgi, 'latest.rhtml', @conf, setup )
else
	DispRef2Latest_cache = nil
end
