#!/usr/bin/env ruby
# todo.rb $Revision: 1.4 $
#
# todo: ToDoリストを表示します．
#
# 準備:
#   1．pluginディレクトリに todo.rb をコピー
#
#   Web上で ToDo ファイルを編集したい場合は，2〜5 も実施する．
#
#   2．index.rb と同じディレクトリに todo.rb をコピー
#      ファイルのモードは index.rb と同じモードにすること．
#   3．skelディレクトリに todo.rhtml をコピー
#   4．tdiary.conf の @header や @footer に <%=todo%> を追加
#   5．todo.rb へのアクセスの認証設定
#      .htaccess の設定例)
#        <FilesMatch "(update|todo).rb">
#            AuthName      tDiary
#            AuthType      Basic
#            AuthUserFile  /home/foo/.htpasswd
#            Require user  foo
#        </FilesMatch>
#
# 解説:
#   ・ ブラウザで todo.rb にアクセスすると ToDo 編集画面が現れるので，
#      画面の指示に従って ToDo を編集
#   ・ ToDo は @cache_path/todo に保存される．編集前の ToDo は todo~
#      にバックアップされる．
#
# tdiary.confで指定するオプション:
#   @options['todo.path']
#     ToDoを保存するファイルを置くディレクトリ．
#     デフォルト値は @cache_path
#   @options['todo.title']
#     ToDoリストのタイトル．
#     デフォルト値は "ToDo:"
#   @options['todo.n']
#     表示するToDoの件数．
#     デフォルトは 10 件．
#
# サンプルCSS:
#
#  div.todo {
#  	font-size: 80%;
#  }
#
#  div.todo-title {
#  	font-weight: bold;
#  }
#
#  div.todo-body {
#  }
#
#  span.todo-priority {
#  	font-weight: bold;
#  }
#
#  span.todo-in-time {
#  }
#
#  span.todo-today {
#  	color: blue;
#  }
#
#  span.todo-too-late {
#  	color: red;
#  	font-weight: bold;
#  }
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
# 

require 'parsedate'
module ToDo
	class ToDo
		attr_reader :prio, :todo, :limit
		def initialize(prio, todo, limit, deleted = nil)
			@prio, @todo, @limit, @deleted = prio, todo, limit, deleted
		end

		def deleted?
			@deleted != ""
		end

		def <=>(other)
			other.prio.to_i <=> @prio.to_i
		end

		def to_s
			r = "#{@deleted}#{@prio}"
			if @limit
				r << "[#{@limit}]"
			end
			r << " #{@todo}"
		end
	end

	def todo_file
		(@options && @options['todo.path'] || @cache_path) + "/todo"
	end

	def todo_parse(src)
		src.each do |l|
			deleted, prio, limit, todo = l.scan(/^(#?)(\d{1,2})(?:\[(.*)\])? +(.+)$/)[0]
			if /^\d+$/ === prio and (1..99).include? prio.to_i and todo
				@todos.push ToDo.new(prio, todo, limit, deleted)
			end
		end
		if @todos.size > 0
			@todos.sort!
		end
	end

	def todo_pretty_print(n)
		s = ''
		s << %Q|<ul>\n|
		now = Time.now
		today = Time.local(now.year, now.month, now.day)
		@todos.each_with_index do |x, idx|
			break if idx >= n
			s << "<li>"
			s << %Q|<del>| if x.deleted?
			s << %Q|<span class="todo-priority">#{'%02d' % x.prio}</span> #{apply_plugin x.todo}|
			if x.limit
				s << "(〜#{x.limit}"
				y, m, d = ParseDate.parsedate(x.limit)
				y = today.year unless y
				if y and m and d
					limit = Time.local(y, m, d)
					diff = ((limit - today)/86400).to_i
					if diff > 0
						s << %Q| <span class="todo-in-time">あと#{diff}日</span>|
					elsif diff == 0
						s << %Q| <span class="todo-today">今日</span>|
					else
						s << %Q| <span class="todo-too-late">#{diff.abs}日遅れ</span>|
					end
				end
				s << ")"
			end
			s << %Q|</del>| if x.deleted?
			s << "</li>\n"
		end
		s << %Q|</ul>\n|
	end
end

if File.basename($0) == File.basename(__FILE__)
# CGI

$KCODE= 'e'
BEGIN { $defout.binmode }

begin
	require 'tdiary'
  
	module TDiary
		class TDiaryTodoBase < TDiaryBase
			include ToDo
			def initialize(cgi, rhtml, conf)
				super
				@todos = Array.new
				@options = @conf.options
				@cache_path = cache_path
			end
		end

		class TDiaryTodo < TDiaryTodoBase
			def initialize( cgi, rhtml, conf )
				super
				todo_load
			end

			def todo_load
				if FileTest::exist?(todo_file)
					todo_parse File::readlines(todo_file)
				end
			end
		end

		class TDiarySaveTodo < TDiaryTodoBase
			def initialize( cgi, rhtml, conf )
				super
				todo_save
			end

			def todo_save
				todos = @cgi.params['todos'][0]
				todo_parse todos.split(/\n/) if todos
				if @todos.size > 0
					backup = todo_file + "~"
					File::unlink(backup) if FileTest::exist?(backup)
					File::rename(todo_file, backup) if FileTest::exist?(todo_file)
					open(todo_file, "w") do |f|
						f.puts @todos.join("\n")
					end
				end
			end
		end
	end

	@cgi = CGI::new
	conf = TDiary::Config::new
	tdiary = nil
  
	begin
		if @cgi.valid?( 'save_todo' )
			tdiary = TDiary::TDiarySaveTodo::new( @cgi, 'todo.rhtml', conf )
		end
	rescue TDiary::TDiaryError
	end
	tdiary = TDiary::TDiaryTodo::new( @cgi, 'todo.rhtml', conf ) if not tdiary

	head = {
		'type' => 'text/html',
		'Vary' => 'User-Agent'
	}
	body = ''
	if @cgi.mobile_agent? then
		body = tdiary.eval_rhtml( 'i.' ).to_sjis
		head['charset'] = conf.charset( true )
		head['Content-Length'] = body.size.to_s
	else
		body = tdiary.eval_rhtml
		head['charset'] = conf.charset
		head['Content-Length'] = body.size.to_s
		head['Pragma'] = 'no-cache'
		head['Cache-Control'] = 'no-cache'
	end
	head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
	head['Last-Modified'] = CGI::rfc1123_date( Time.new )
	print @cgi.header( head )
	print body if /HEAD/i !~ @cgi.request_method
rescue Exception
	puts "Content-Type: text/plain\n\n"
	puts "#$! (#{$!.type})"
	puts ""
	puts $@.join( "\n" )
end
# CGI
else
# PLUGIN
extend ToDo

@todos = []

def todo
	n = @options && @options['todo.n'] || 10
	title = @options && @options['todo.title'] || 'ToDo:'
	todo_parse File::readlines(todo_file) if FileTest::exist?(todo_file)
	<<TODO
<div class="todo">
	<div class="todo-title">
		<p>#{title}</p>
	</div>
	<div class="todo-body">
#{todo_pretty_print n}
	</div>
</div>
TODO
end

def navi_t(name = "ToDo編集")
	%Q|<span class="adminmenu"><a href="todo.rb">#{name}</a></span>\n|
end
# PLUGIN
end
# vim: ts=3
