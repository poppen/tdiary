=begin
= Meta-scheme plugin((-$Id: referer_scheme.rb,v 1.1 2003-12-16 17:26:58 zunda Exp $-))
本日のリンク元置換リストの記述を楽にします。

今のところ、少なくとも ruby 1.6.7 (2002-03-01) ではうまく動きません。

== 利用方法
このプラグインを、プラグインのディレクトリに入れるかプラグイン選択プラグ
インから有効にしてください。

次に、設定、リンク元から、リンク元置換リストを編集して、tdiary:や
hatena:というプレフィックス(メタ・スキームと呼ぶことにします)をURLの前に
付けてください。

これにより、日付を置換するルールを書かないでも、置換後の文字列に自動的に
日付などを挿入することができます。

例えば、次のような記述をしてください。
* tdiary:http://tdiary.tdiary.net/ tDiary.net運営日誌
* tdiarynet:foo((-http://foo.tdiary.net/に展開されます-)) fooさんの日記
* hatena:bar((-http://d.hatena.ne.jp/bar/に展開されます-)) barさんの日記
この例では、URLに日付が含まれれば、(YYYY-MM-DD)という形式で追加します。

== 注意
tdiary:で始まるURLは、
* 括弧を使わないでください。
* /で終わらせてください。

tdiarynet:やhatena:で始まるURLは、
* 括弧を使わないでください。
* URLとしてはユーザーIDだけを指定してください。

== メタ・スキームの作り方
リンク元置換リストのURLの正規表現の文字列に対して、/^(\w+):/という正規表
現で一致する文字列がメタ・スキームとして検出されます。
  def scheme_スキーム名( url, name, block )
    :
    block.call( url_variants, name_variants )
    :
  end
という@conf.referer_tableの特異メソッドをイテレータとして定義しておけば、
置換リストの記述に応じてこのメソッドが呼ばれます。urlには
「メタ・スキーム名:」を除いた正規表現が渡されることに注意してください。

== Copyright
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

class << @conf.referer_table
	private

	TdiaryDates = [
			['(?:\\?date=)?(\d{4})(\d{2})(\d{2})(?:\.html)?.*', '(\1-\2-\3)'],
			['(?:\\?date=)?(\d{4})(\d{2})(?:\.html)?.*', '(\1-\2)'],
			['(?:\\?date=)?(\d{2})(\d{2})(?:\.html)?.*', '(\1-\2)'],
	]
	TdiaryNet = '.tdiary.net/'
	HatenaHost = 'http://d.hatena.ne.jp/'

	def scheme_tdiary( url, name, block )
		TdiaryDates.each do |a|
			block.call( url + a[0], name + a[1] )
		end
		block.call( url, name )
	end

	def scheme_tdiarynet( url, name, block )
		TdiaryDates.each do |a|
			block.call( "http://#{url}#{TdiaryNet}/#{a[0]}", name + a[1] )
		end
		block.call( "http://#{url}#{TdiaryNet}/", name )
	end

	def scheme_hatena( url, name, block )
		[
			['(\d{4})(\d{2})(\d{2}).*', '(\1-\2-\3)'],
			['(\d{4})(\d{2}).*', '(\1-\2)'],
		].each do |a|
			block.call( "#{HatenaHost}#{url}/#{a[0]}", name + a[1] )
		end
		block.call( "#{HatenaHost}#{url}/", name )
	end

end
