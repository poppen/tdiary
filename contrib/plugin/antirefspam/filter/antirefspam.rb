#
# antirefspamfilter.rb
#
# Copyright (c) 2004 T.Shimomura <redbug@netlife.gr.jp>
#

=begin

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
          filename = File.join(@conf.data_path,"cache","AntiRefSpamFilter",filename)
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

        @work_path = File.join(@conf.data_path,"AntiRefSpamFilter")
        @spamurl_list = File.join(@work_path,"spamurls")  # referer spam のリンク元一覧
        @spamip_list  = File.join(@work_path,"spamips")   # referer spam のIP一覧
        @safeurl_list = File.join(@work_path,"safeurls")  # おそらくは問題のないリンク元一覧

        # 自分の日記内からのリンクは信頼する
        if check(referer)
          return true
        end

        # 信頼できるURL に合致するか
        if trustledurl=@conf['antirefspam.trustedurl']
          trustledurl.to_s.each_line do |trusted|
            trusted.sub!(/\r?\n/,'')
            next trusted=~/\A(\#|\s*)\z/
            
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
          body = ""
          begin
            Net::HTTP.start(uri.host, uri.port) do |http|
              if uri.path == ""
                response = http.get("/")
              else
                response = http.get(uri.request_uri)
              end
              body = response.body
            end

            # body に日記の URL が含まれていなければ SPAM とみなす
            unless check(body)
              File::open(@spamurl_list, "a+") {|f|
                f.puts referer
              }
              File::open(@spamip_list, "a+") {|f|
                f.puts [@cgi.remote_addr, Time.now.utc.strftime("%Y/%m/%d %H:%m:%s UTC")].join("\t")
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

        rescue StandardError, Timeout::Error
          # 現在チェック中なら、今回はリンク元に勘定しない
          return false
        ensure
          File::delete(File.join(@work_path,uri.host))
        end

        return true
      end
    end
  end
end
