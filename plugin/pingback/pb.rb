#!/usr/bin/env ruby
# pb.rb $Revision: 1.1 $
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Copyright (c) 2004 MoonWolf <moonwolf@moonwolf.com>
# Distributed under the GPL
#

BEGIN { $defout.binmode }
$KCODE = 'n'

if FileTest::symlink?( __FILE__ ) then
  org_path = File::dirname( File::readlink( __FILE__ ) )
else
  org_path = File::dirname( __FILE__ )
end
$:.unshift org_path.untaint
require 'tdiary'

module TDiary
  #
  # exception class for PingBack
  #
  class TDiaryPingBackError < StandardError
  end
  
  #
  # class TDiaryPingBackBase
  #
  class TDiaryPingBackBase < TDiaryBase
    public :mode
    def initialize( cgi, rhtml, conf )
      super
      date = @cgi.request_uri.scan(%r!/(\d{4})(\d\d)(\d\d)!)[0]
      if date
        @date = Time::local(*date)
      else
        @date = Time::now
      end
    end
    
    def diary_url
      @conf.base_url + @conf.index.sub(%r|^\./|, '') + @plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
    end
  end
  
  #
  # class TDiaryPingBackReceive
  #  receive PingBack ping and store as comment
  #
  class TDiaryPingBackReceive < TDiaryPingBackBase
    def initialize( cgi, rhtml, conf )
      super
      @error = nil
      
      sourceURI = @cgi.params['sourceURI'][0]
      targetURI = @cgi.params['targetURI'][0]
      body = [sourceURI,targetURI].join("\n")
      @cgi.params['name'] = ['PingBack']
      @cgi.params['body'] = [body]
      
      @comment = Comment::new('PingBack', '', body)
      begin
        @io.transaction( @date ) do |diaries|
          @diaries = diaries
          @diary = @diaries[@date.strftime('%Y%m%d')]
          if @diary and comment_filter( @diary, @comment ) then
            @diary.add_comment(@comment)
            DIRTY_COMMENT
          else
            @comment = nil
            DIRTY_NONE
          end
        end
      rescue
        @error = $!.message
      end
    end
    
    def eval_rhtml( prefix = '' )
      raise TDiaryPingBackError.new(@error) if @error
      load_plugins
      @plugin.instance_eval { update_proc }
    end
  end
end

require 'xmlrpc/server'
server = XMLRPC::CGIServer.new
server.add_handler("pingback.ping") do |sourceURI,targetURI|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['REQUEST_URI'] = targetURI
  @cgi = CGI::new
  @cgi.params['sourceURI'] = [sourceURI]
  @cgi.params['targetURI'] = [targetURI]
  conf = TDiary::Config::new(@cgi)
  tdiary = TDiary::TDiaryPingBackReceive::new( @cgi, 'day.rhtml', conf )
  return "PingBack receive sucess"
end
server.serve
# vim: ts=3
