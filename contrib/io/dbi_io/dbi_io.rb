#
# dbi_io.rb: DBI IO for tDiary 2.x. $Revision: 1.1 $
#
# NAME             dbi_io
#
# DESCRIPTION      tDiary向けDBI用IOクラス
#                  詳細は、README.jaを参照してください
#
# Copyright        (C) 2003 ma2tak <ma2tak@ma2tak.dyndns.org>
#                  (C) 2004 moonwolf <moonwolf@mooonwolf.com>
#
# You can distribute this under GPL.
require 'dbi'

module TDiary
  
  class DbiIO < IOBase
    module CommentIO
      def restore_comment(diaries)
        begin
          diaries.each {|date, diary_object|
            @dbh.select_all("SELECT diary_id, name, mail, last_modified, visible, no, author, comment FROM commentdata WHERE author=? AND diary_id=? ORDER BY no;", @dbi_author, date) {|diary_id, name, mail, last_modified, visible, no, author, comment|
              comment = Comment::new(name, mail, comment, Time::at(last_modified.to_i))
              comment.show = visible
              diary_object.add_comment(comment)
            }
          }
        rescue Errno::ENOENT
        end
      end

      def store_comment(diaries)
        begin
          diaries.each {|date, diary|
            no = 0
            diary.each_comment(diary.count_comments(true)) {|com|
              no += 1
              param = [com.name, com.mail, com.date.to_i, com.visible?, com.body, @dbi_author, date, no]
              sth = @dbh.execute("UPDATE commentdata SET name=?, mail=?, last_modified=?, visible=?, comment=? WHERE author=? AND diary_id=? AND no=?;", *param)
              if sth.rows == 0
                @dbh.execute("INSERT INTO commentdata (name, mail, last_modified, visible, comment, author, diary_id, no) VALUES (?,?,?,?,?,?,?,?);", *param)
              end
            }
          }
        rescue Errno::ENOENT
        end
      end
    end

    module RefererIO
      def restore_referer(diaries)
        begin
          diaries.each {|date, diary_object|
            sql = "SELECT diary_id, count, ref FROM refererdata WHERE author='#{@dbi_author}' AND diary_id=#{date};"
            num = 0
            @dbh.select_all(sql) {|diary_id, count, ref|
              num += 1
              diary_object.add_referer(ref.chomp, count.to_i)
            }
          }
        rescue Errno::ENOENT
        end
      end

      def store_referer(diaries)
        begin
          diaries.each {|date, diary|
            no = 0
            diary.each_referer(diary.count_referers) {|count,ref|
              no += 1
              param = [count, ref, @dbi_author, date, no]
              sth = @dbh.execute("UPDATE refererdata SET count=?, ref=? WHERE author=? AND diary_id=? AND no=?;", *param)
              if sth.rows==0
                @dbh.execute("INSERT INTO refererdata (count, ref, author, diary_id, no ) VALUES (?,?,?,?,?);", *param)
              end
            }
          }
        rescue Errno::ENOENT
        end
      end
    end
    
    include CommentIO
    include RefererIO
    
    def initialize(tdiary)
      @tdiary    = tdiary
      @dbi_url    = tdiary.conf.dbi_driver_url
      @dbi_user   = tdiary.conf.dbi_user
      @dbi_passwd = tdiary.conf.dbi_passwd
      @dbi_author = tdiary.conf.dbi_author || 'default'
      @dbh       = DBI.connect(@dbi_url, @dbi_user, @dbi_passwd)
      load_styles
    end
    
    def calendar
      calendar = {}
      sql = "SELECT DISTINCT year, month FROM diarydata GROUP BY year, month ORDER BY year, month;"
      @dbh.select_all(sql) {|year, month|
        ary = calendar[year] || Array.new
        ary << month
        calendar[year] = ary
      }
      
      calendar
    end
    
    #
    # block must be return boolean which dirty diaries.
    #
    def transaction(date)
      @dbh.transaction {
        date_string = date.strftime("%Y%m%d")
        diaries = {}
        cache = @tdiary.restore_parser_cache(date, 'defaultio')
        unless cache
          restore(date_string, diaries)
          restore_comment(diaries)
          restore_referer(diaries)
        else
          diaries.update(cache)
        end
        dirty = yield(diaries) if iterator?
        store(diaries)  if dirty & TDiary::TDiaryBase::DIRTY_DIARY != 0
        store_comment(diaries)  if dirty & TDiary::TDiaryBase::DIRTY_COMMENT != 0
        store_referer(diaries)  if dirty & TDiary::TDiaryBase::DIRTY_REFERER != 0
        if dirty or not cache
          @tdiary.store_parser_cache(date, 'defaultio', diaries)
        end
      }
    end
    
    def diary_factory(date, title, body, style = 'tDiary')
      styled_diary_factory(date, title, body, style)
    end
    
    # HNF移行ツールのため、作成
    def restore_diary(date)
      diaries = {}
      restore(date, diaries, false)
      diaries
    end
    
    private
    def restore(date, diaries, month=true)
      sql = "SELECT diary_id, title, last_modified, visible, body, style FROM DiaryData WHERE author='#{@dbi_author}' and diary_id='#{date}';"
      if month == true
        if /(\d\d\d\d)(\d\d)(\d\d)/ =~ date
          sql = "SELECT diary_id, title, last_modified, visible, body, style FROM DiaryData WHERE author='#{@dbi_author}' AND year='#{$1}' AND month='#{$2}';"
        end
      end
      @dbh.select_all(sql) {|diary_id, title, last_modified, visible, body, style|
        style = 'tdiary' if style.nil? || style.empty?
        style = style.downcase
        diary = eval("#{style(style)}::new(diary_id, title, body, Time::at(last_modified.to_i))")
        diary.show(visible)
        diaries[diary_id] = diary
      }
    end
    
    def store(diaries)
      diaries.each {|date, diary|
        # save diaries
        if /(\d\d\d\d)(\d\d)(\d\d)/ =~ date
          year  = $1
          month = $2
          day   = $3
        end
        visible = (diary.visible? ? "true" : "false")

        param = [year, month, day, diary.title, diary.last_modified.to_i, visible, diary.to_src, diary.style, @dbi_author, date]
        sth = @dbh.execute("UPDATE diarydata SET year=?, month=?, day=?, title=?, last_modified=?, visible=?, body=?, style=? WHERE author=? AND diary_id=?", *param)
        if sth.rows == 0
          @dbh.execute("INSERT INTO diarydata (year, month, day, title, last_modified, visible, body, style, author, diary_id) VALUES (?,?,?,?,?,?,?,?,?,?);", *param)
        end
      }
    end
    
    # 追加メソッド for test
    def delete(diaries)
      diaries.each {|date, diary|
        sql = "DELETE FROM diarydata WHERE author=#{@dbi_author} AND diary_id=#{date};"
        @dbh.execute(sql)
      }
    end
    
  end
  
end
