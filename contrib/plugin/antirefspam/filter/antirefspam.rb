#
# antirefspamfilter.rb
#
# Copyright (c) 2004 T.Shimomura <redbug@netlife.gr.jp>
#

=begin

ver 0.9 2004/11/24
	リンク元置換リストにマッチするリンク元を信頼する機能を追加 (thanks to Shun-ichi TAHARA)
	コメントの制限に正規表現を使えるようにした
	HTTP.version_1_2 系を使えなかった場合に動作がおかしかった不具合を修正
	spamips に出力される時刻の分/秒部分がおかしかったのを修正
	その他エラーが起きにくいように処理を変更

ver 0.8 2004/11/15
	プロキシーサーバーを指定する機能を追加
	ver 0.6m〜0.71 で、Ruby 1.6 系でエラーが出ることがあった不具合を修正

ver 0.71 2004/11/12
	ver 0.6m と ver 0.7 で、"信頼するリンク元" の指定が適用されなくなっていた不具合を修正

ver 0.7 2004/11/11
	一部のアンテナで、設定によって更新日時が取れないことがあった問題に対処
	コメントスパムに対処するため、コメントに制限をかける機能を追加

ver 0.6m 2004/11/07
	ソースのインデント変更
	if not→unlessへの書き換え等

ver 0.6 2004/11/07
	トップページURL以外の許容するリンク先を指定できるようにした。
	設定画面の言語リソースを分割した。

ver 0.5 2004/10/31
	信頼できるURL に正規表現を使えるようにした
	safeurls, spaurls に、同一の URL が２つ連続で記録される問題に対処した(つもり)

ver 0.4 2004/10/20
	Ruby 1.8.2 (preview2) で動作しなかった不具合を修正
	接続するポートを80からuri.portに変更 (thanks to MoonWolf)

ver 0.3 2004/09/30
	負荷を下げるための修正をちょっとだけ入れた

ver 0.2 2004/09/27
	信頼できるURLの一覧を設定画面から変更できるようにした

ver 0.1 2004/09/15
	最初のバージョン

=end

require 'net/http'
require 'uri'

module TDiary
  module Filter

    class AntirefspamFilter < Filter
      def debug_out(filename, str)
        if $debug
          filename = File.join(@conf.data_path,"AntiRefSpamFilter",filename)
          File::open(filename, "a+") {|f|
            f.puts str
          }
        end
      end

      # str に指定された文字列が適切なリンク先を含んでいるかをチェック
      def check(str)
        # str にトップページURLが含まれているかどうか
        unless @conf.index_page.empty?
          if str.include? @conf.index_page
            return true
          end
        end

        # str に許容するリンク先が含まれているかどうか
        if (myurl = @conf['antirefspam.myurl']) && !myurl.empty?
          if str.include? myurl
            return true
          end
          
          url = myurl.gsub("/", "\\/").gsub(":", "\\:")
          exp = Regexp.new(url)
          if exp =~ str
            return true
          end
        end
        return false
      end

      def referer_filter(referer)
        # リンク元が無い
        unless referer
          return true
        end
        # 一部のアンテナで更新時刻が取れなくなる問題に対応するため、リンク元が１文字以内の場合は許容する
        if referer.size <= 1
          return true
        end

        @work_path = File.join(@conf.data_path,"AntiRefSpamFilter")
        @spamurl_list = File.join(@work_path,"spamurls")  # referer spam のリンク元一覧
        @spamip_list  = File.join(@work_path,"spamips")   # referer spam のIP一覧
        @safeurl_list = File.join(@work_path,"safeurls")  # おそらくは問題のないリンク元一覧

        # 自分の日記内からのリンクは信頼する
        if check(referer)
          return true
        end

        # 信頼できるURL に合致するか
        if trustedurls=@conf['antirefspam.trustedurl']
          trustedurls.to_s.each_line do |trusted|
            trusted.sub!(/\r?\n/,'')
            next if trusted=~/\A(\#|\s*)\z/
            
            # まずは "信頼できる URL" が referer に含まれるかどうか
            if referer.include? trusted
              debug_out("trusted1", trusted+" --- "+referer)
              return true
            end
            
            # 含まれなかった場合は "信頼できる URL" を正規表現とみなして再チェック
            begin
              url = trusted.gsub("/", "\\/").gsub(":", "\\:")
              exp = Regexp.new(url)
              
              if referer =~ exp
                debug_out("trusted2", trusted+" --- "+referer)
                return true
              end
            rescue
              debug_out("error_config", trusted)
            end
          end
        end

        # URL置換リストを見る
        if @conf['antirefspam.checkreftable'] != nil
          if @conf['antirefspam.checkreftable'].to_s == 'true'
            @conf.referer_table.each do |url, name|
              begin
                if /#{url}/i =~ referer
                  debug_out("trusted3", url+" --- "+referer)
                  return true
                end
              rescue
                debug_out("error_config", url)
              end
            end
          end
        end

        # 前準備
        unless File.exist? @work_path
          Dir::mkdir(@work_path)
        end
        unless File.exist? @spamurl_list
          File::open(@spamurl_list, "a").close
        end
        unless File.exist? @safeurl_list
          File::open(@safeurl_list, "a").close
        end

        uri = URI.parse(referer)
        # チェック時には対象のドメイン名を持った一時ファイルを作る
        begin
          File::open(File.join(@work_path,uri.host), File::RDONLY | File::CREAT | File::EXCL).close

          # 一度 SPAM URL とみなしたら以後は以後は拒否
          spamurls = IO::readlines(@spamurl_list).map {|url| url.chomp }
          if spamurls.include? referer
            return false
          end

          # 一度 SPAM URL でないと判断したら以後は許可
          safeurls = IO::readlines(@safeurl_list).map {|url| url.chomp }
          if safeurls.include? referer
            return true
          end

          # リンク元 URL の HTML を引っ張ってくる
          Net::HTTP.version_1_2   # おまじないらしい
          proxy_server = nil
          proxy_port = nil
          unless @conf['antirefspam.proxy_server'].empty?
            proxy_server = @conf['antirefspam.proxy_server']
            proxy_port = @conf['antirefspam.proxy_port']
          end
          body = ""
          begin
            Net::HTTP::Proxy(proxy_server, proxy_port).start(uri.host, uri.port) do |http|
              if uri.path == ""
                response, = http.get("/")
              else
                response, = http.get(uri.request_uri)
              end
              body = response.body
            end

            # body に日記の URL が含まれていなければ SPAM とみなす
            unless check(body)
              File::open(@spamurl_list, "a+") {|f|
                f.puts referer
              }
              File::open(@spamip_list, "a+") {|f|
                f.puts [@cgi.remote_addr, Time.now.utc.strftime("%Y/%m/%d %H:%M:%S UTC")].join("\t")
              }
              return false
            else
              File::open(@safeurl_list, "a+") {|f|
                f.puts referer
              }
            end
          rescue
            # エラーが出た場合は @spamurl_list に入れない＆リンク元にも入れない
            return false
          end

        rescue StandardError, TimeoutError
          # 現在チェック中なら、今回はリンク元に勘定しない
          return false
        ensure
          begin
            File::delete(File.join(@work_path,uri.host))
          rescue
          end
        end

        return true
      end

      def comment_filter( diary, comment )
        # ツッコミに日本語(ひらがな/カタカナ)が含まれていなければ不許可
        if @conf['antirefspam.comment_kanaonly'] != nil
          if @conf['antirefspam.comment_kanaonly'].to_s == 'true'
            unless comment.body =~ /[ぁ-んァ-ヴー]/
              return false
            end
          end
        end

        # ツッコミの文字数が指定した上限以内でないなら不許可
        maxsize = @conf['antirefspam.comment_maxsize'].to_i
        if maxsize > 0
          unless comment.body.size <= maxsize
            return false
          end
        end

        # NGワードが１つでも含まれていたら不許可
        if @conf['antirefspam.comment_ngwords'] != nil
          ngwords = @conf['antirefspam.comment_ngwords']
          ngwords.to_s.each_line do |ngword|
            ngword.sub!(/\r?\n/,'')
            if comment.body.downcase.include? ngword.downcase
              return false
            end

            # 含まれなかった場合は "NGワード" を正規表現とみなして再チェック
            begin
              if comment.body =~ Regexp.new( ngword, Regexp::MULTILINE )
                return false
              end
            rescue
              debug_out("error_config2", ngword)
            end
          end
        end

        return true
      end
    end
  end
end
