#!/usr/bin/env ruby
# xmlrpc.rb $Revision: 1.2 $
#
# Copyright (c) 2004 MoonWolf <moonwolf@moonwolf.com>
# Distributed under the GPL
#
# require Ruby1.8 or xml-rpc(http://raa.ruby-lang.org/project/xml-rpc/)
# require Uconv

BEGIN { $defout.binmode }
$KCODE = 'n'

if FileTest::symlink?( __FILE__ ) then
  org_path = File::dirname( File::readlink( __FILE__ ) )
else
  org_path = File::dirname( __FILE__ )
end
$:.unshift org_path.untaint
require 'tdiary'
require 'uconv'
require 'uri'

eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
  class TDiaryBase
    attr_reader :date
    public :[]
    public :calendar
  end
  class TDiaryLatest
    public :latest
  end
end
MODIFY_CLASS

require 'xmlrpc/server'
if defined?(MOD_RUBY)
  server = XMLRPC::ModRubyServer.new
else
  server = XMLRPC::CGIServer.new
end

server.add_handler('blogger.newPost') do |appkey, blogid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    begin
      @cgi.params['title'] = ['']
      @cgi.params['body'] = [Uconv.u8toeuc(content)]
      @cgi.params['hide']  = publish ? [] : ['true']
      tdiary = ::TDiary::TDiaryAppend::new( @cgi, 'show.rhtml', conf )
      body = tdiary.eval_rhtml
      tdiary.date.strftime('%Y%m%d')
    rescue ::TDiary::ForceRedirect => redirect
      tdiary.date.strftime('%Y%m%d')
    end
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('blogger.editPost') do |appkey, postid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    begin
      @cgi.params['title']   = ['']
      @cgi.params['body']    = [Uconv.u8toeuc(content)]
      @cgi.params['hide']    = publish ? [] : ['true']
      @cgi.params['year']    = [postid[0..3]]
      @cgi.params['month']   = [postid[4..5]]
      @cgi.params['day']     = [postid[6..7]]
      tdiary = ::TDiary::TDiaryReplace::new( @cgi, 'show.rhtml', conf )
      body = tdiary.eval_rhtml
      tdiary.date.strftime('%Y%m%d')
    rescue ::TDiary::ForceRedirect => redirect
      tdiary.date.strftime('%Y%m%d')
    end
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('blogger.deletePost') do |appkey, postid, username, password, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    begin
      @cgi.params['title'] = ['']
      @cgi.params['body']  = ['']
      @cgi.params['hide']  = ['true']
      @cgi.params['year']  = [postid[0..3]]
      @cgi.params['month'] = [postid[4..5]]
      @cgi.params['day']   = [postid[6..7]]
      tdiary = ::TDiary::TDiaryReplace::new( @cgi, 'show.rhtml', conf )
      body = tdiary.eval_rhtml
      raise XMLRPC::FaultException.new(1,"can't delete")
    rescue ::TDiary::ForceRedirect => redirect
      true
    end
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('blogger.getRecentPosts') do |appkey, blogid, username, password, numberOfPosts|
  ENV['REQUEST_METHOD'] = 'POST'
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    result = []
    @cgi.params['title'] = ['']
    @cgi.params['body']  = ['']
    @cgi.params['hide']  = ['true']
    conf.latest_limit = numberOfPosts
    tdiary = ::TDiary::TDiaryLatest::new( @cgi, 'latest.rhtml', conf )
    tdiary.latest(numberOfPosts) {|diary|
      author = Uconv.euctou8(conf['xmlrpc.userid'])
      diary.each_section {|sec|
        if sec.author
          author = sec.author
          break
        end
      }
      result << {
        'postid'      => diary.date.strftime('%Y%m%d'),
        'userid'      => Uconv.euctou8(author),
        'content'     => Uconv.euctou8(diary.to_src),
        'dateCreated' => diary.last_modified.utc
      }
    }
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('blogger.getUsersBlogs') do |appkey, username, password|
  ENV['REQUEST_METHOD'] = 'POST'
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    result = [
      {
        'blogid'   => conf['xmlrpc.blogid'],
        'blogName' => Uconv.euctou8(conf.html_title),
        'url'      => conf.base_url
      }
    ]
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('blogger.getUserInfo') do |appkey, username, password|
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    result = {
      'nickname'  => Uconv.euctou8(conf.author_name),
      'email'     => conf.author_mail,
      'url'       => conf.base_url,
      'lastname'  => Uconv.euctou8(conf['xmlrpc.lastname']),
      'firstname' => Uconv.euctou8(conf['xmlrpc.firstname']),
      'userid'    => Uconv.euctou8(conf['xmlrpc.userid'])
    }
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('metaWeblog.newPost') do |blogid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    begin
      @cgi.params['title'] = [Uconv.u8toeuc(content['title'] || '')]
      @cgi.params['body']  = [Uconv.u8toeuc(content['description'] || '')]
      @cgi.params['hide']  = publish ? [] : ['true']
      tdiary = ::TDiary::TDiaryAppend::new( @cgi, 'show.rhtml', conf )
      body = tdiary.eval_rhtml
      tdiary.date.strftime('%Y%m%d')
    rescue ::TDiary::ForceRedirect => redirect
      tdiary.date.strftime('%Y%m%d')
    rescue
      raise $!.inspect + "\n" + $!.backtrace.join("\n")
    end
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('metaWeblog.editPost') do |postid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    begin
      @cgi.params['title'] = [Uconv.u8toeuc(content['title'])]
      @cgi.params['body']  = [Uconv.u8toeuc(content['description'])]
      @cgi.params['hide']  = publish ? [] : ['true']
      @cgi.params['year']  = [postid[0..3]]
      @cgi.params['month'] = [postid[4..5]]
      @cgi.params['day']   = [postid[6..7]]
      tdiary = ::TDiary::TDiaryReplace::new( @cgi, 'show.rhtml', conf )
      body = tdiary.eval_rhtml
      true
    rescue ::TDiary::ForceRedirect => redirect
      true
    end
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('metaWeblog.getPost') do |postid, username, password|
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    @cgi.params['date'] = [postid]
    tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', conf )
    result = []
    date = Time::local( *postid.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] ) + 12*60*60
    diary = tdiary[date]
    author  = Uconv.euctou8(conf['xmlrpc.userid'])
    title   = nil
    diary.each_section {|sec|
      title   ||= sec.stripped_subtitle
      author  ||= sec.author
    }
    
    result = {
      'userid'       => Uconv.euctou8(author),
      'dateCreated'  => diary.last_modified.utc,
      'postid'       => postid,
      'description'  => Uconv.euctou8(diary.to_src),
      'title'        => Uconv.euctou8(title || ''),
      'link'         => conf.base_url + conf.index.sub(%r|^\./|, '') + postid + '.html',
      'permaLink'    => conf.base_url + conf.index.sub(%r|^\./|, '') + postid + '.html',
      'mt_excerpt'   => Uconv.euctou8(diary.to_src),
      'mt_text_mode' => '',
      'mt_allow_comments' => 1,
      'mt_allow_pings' => 1,
      'mt_convert_breaks' => '__default__',
      'mt_keyword'   => ''
    }
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('metaWeblog.getRecentPosts') do |blogid, username, password, numberOfPosts|
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    result = []
    @cgi.params['title'] = ['']
    @cgi.params['body']  = ['']
    @cgi.params['hide']  = ['true']
    conf.latest_limit = numberOfPosts
    tdiary = ::TDiary::TDiaryLatest::new( @cgi, 'latest.rhtml', conf )
    tdiary.latest(numberOfPosts) {|diary|
      title  = nil
      title  = diary.title if diary.title && !diary.title.empty?
      author = Uconv.euctou8(conf['xmlrpc.userid'])
      diary.each_section {|sec|
        title   ||= sec.stripped_subtitle
        author  ||= sec.author
      }
      postid = diary.date.strftime('%Y%m%d')
      result << {
        'dateCreated'       => diary.last_modified.utc,
        'userid'            => Uconv.euctou8(author),
        'postid'            => postid,
        'description'       => Uconv.euctou8(diary.to_src),
        'title'             => Uconv.euctou8(title || ''),
        'link'              => conf.base_url + conf.index.sub(%r|^\./|, '') + postid + '.html',
        'permaLink'         => conf.base_url + conf.index.sub(%r|^\./|, '') + postid + '.html',
        'mt_excerpt'        => Uconv.euctou8(diary.to_src),
        'mt_text_more'      => '',
        'mt_allow_comments' => 1,
        'mt_allow_pings'    => 1,
        'mt_convert_breaks' => '__default__',
        'mt_keywords'       => '',
      }
    }
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('metaWeblog.newMediaObject') do |blogid, username, password, file|
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    image_dir = conf['image.dir'] || './images/'
    image_dir.chop! if /\/$/ =~ image_dir
    image_url = conf['image.url'] || './images/'
    image_url.chop! if /\/$/ =~ image_url
    name = file['name']
    bits = file['bits']
    path = File.join(image_dir, name)
    open(path,'wb') {|f|
      f.write bits.to_s
    }
    {'url' => (URI.parse(conf.base_url) + (image_url + '/' + name)).to_s }
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('mt.getRecentPostTitles') do |blogid, username, password, numberOfPosts|
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    result = []
    @cgi.params['title'] = ['']
    @cgi.params['body']  = ['']
    @cgi.params['hide']  = ['true']
    conf.latest_limit = numberOfPosts
    tdiary = ::TDiary::TDiaryLatest::new( @cgi, 'latest.rhtml', conf )
    tdiary.latest(numberOfPosts) {|diary|
      author = Uconv.euctou8(conf['xmlrpc.userid'])
      diary.each_section {|sec|
        if sec.author
          author = sec.author
          break
        end
      }
      postid = diary.date.strftime('%Y%m%d')
      result << {
        'dateCreated'       => diary.last_modified.utc,
        'userid'            => Uconv.euctou8(author),
        'postid'            => postid,
        'title'             => Uconv.euctou8(diary.title),
      }
    }
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('mt.getCategoryList') do |blogid, username, password|
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    @cgi.params['date'] = [Time.now.strftime('%Y%m%d')]
    tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', conf )
    list = []
    tdiary.calendar.each do |y, ms|
      ms.each do |m|
        ym = "#{y}#{m}"
        @cgi.params['date'] = [ym]
        m = ::TDiary::TDiaryMonth.new(@cgi, '', conf)
        sections = {}
        m.diaries.each do |ymd, diary|
          next if !diary.visible?
          diary.each_section do |s|
            list |= s.categories unless s.categories.empty?
          end
        end
      end
    end
    list = list.sort.uniq
    result = []
    list.each {|c|
      result << {
        'categoryId'   => Uconv.euctou8(c),
        'categoryName' => Uconv.euctou8(c)
      }
    }
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('mt.getPostCategories') do |postid, username, password|
  @cgi = CGI::new
  @cgi.params['date'] = [postid]
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', conf )
    result = []
    date = Time::local( *postid.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] ) + 12*60*60
    diary = tdiary[date]
    diary.each_section {|sec|
      sec.categories.each_with_index {|cat,index|
        result << {
          'categoryName' => Uconv.euctou8(cat),
          'categoryId'   => Uconv.euctou8(cat),
          'isPrimary'    => index==0
        }
      }
      break
    }
    result
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('mt.setPostCategories') do |postid, username, password, categories|
  @cgi = CGI::new
  conf = ::TDiary::Config::new(@cgi)
  if username==Uconv.euctou8(conf['xmlrpc.username']) && password==Uconv.euctou8(conf['xmlrpc.password'])
    begin
      @cgi.params['date']  = [postid]
      tdiary = ::TDiary::TDiaryDay::new( @cgi, "day.rhtml", conf )
      time = Time::local( *postid.scan(/^(\d{4})(\d\d)(\d\d)$/)[0] ) + 12*60*60
      diary = tdiary[ time ]
      ENV['REQUEST_METHOD'] = 'POST'
      @cgi.params.delete 'date'
      @cgi.params['old']   = [postid]
      @cgi.params['hide']  = diary.visible? ? [] : ['true']
      @cgi.params['title'] = [diary.title]
      @cgi.params['year']  = [postid[0..3]]
      @cgi.params['month'] = [postid[4..5]]
      @cgi.params['day']   = [postid[6..7]]
      src = diary.to_src
      src = src.sub(/\A((\#|!)?)(\[.+?\])*/e) {
        $1 + categories.map {|c| "[" + Uconv.u8toeuc(c) + "]" }.join
      }
      @cgi.params['body']  = [src]
      tdiary = ::TDiary::TDiaryReplace::new( @cgi, 'show.rhtml', conf )
      #body = tdiary.eval_rhtml
      true
    rescue ::TDiary::ForceRedirect => redirect
      true
    rescue Exception
      raise XMLRPC::FaultException.new(1,$!.to_s + "\n" + $!.backtrace.join("\n"))
    end
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('mt.supportedMethods') do
  [
    'blogger.newPost',
    'blogger.editPost',
    'blogger.getRecentPosts',
    'blogger.getUsersBlogs',
    'blogger.getUserInfo',
    'blogger.deletePost',
    'metaWeblog.getPost',
    'metaWeblog.newPost',
    'metaWeblog.editPost',
    'metaWeblog.getRecentPosts',
    'metaWeblog.newMediaObject',
    'mt.getCategoryList',
    'mt.setPostCategories',
    'mt.getPostCategories',
    'mt.getTrackbackPings',
    'mt.supportedTextFilters',
    'mt.getRecentPostTitles',
    'mt.publishPost'
  ]
end

server.add_handler('mt.supportedTextFilters') do
  ['__default__']
end

server.add_handler('mt.getTrackbackPings') do |postid|
  @cgi = CGI::new
  @cgi.params['date'] = [postid]
  conf = ::TDiary::Config::new(@cgi)
  tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', conf )
  result = []
  date = Time::local( *postid.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] ) + 12*60*60
  tdiary[date].each_visible_trackback(100) {|com,i|
    url, name, title, excerpt = com.body.split( /\n/,4 )
    result << {
      'pingURL'   => url,
      'pingIP'    => '127.0.0.1',
      'pingTitle' => Uconv.euctou8(title),
    }
  }
  result
end

server.add_handler('mt.publishPost') do |postid, username, password|
  true
end

server.add_handler('mt.setNextScheduledPost') do |postid, dateCreated, username, password|
  true
end

server.serve
