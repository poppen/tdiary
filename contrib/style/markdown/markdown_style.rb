#
# markdown_style.rb: Markdown style for tDiary 2.x format. $Revision: 1.3 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'Markdown'
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# Copyright (C) 2004, MoonWolf <moonwolf@moonwolf.com>
# You can distribute this under GPL.
#
require 'bluecloth'

module TDiary
  class MarkdownSection
    attr_reader :subtitle, :author
    attr_reader :categories, :stripped_subtitle
    attr_reader :subtitle_to_html, :stripped_subtitle_to_html, :body_to_html

    def initialize( fragment, author = nil )
      @author = author
      @subtitle, @body = fragment.split( /\n/, 2 )
      @body ||= ''
      
      @categories = get_categories
      @stripped_subtitle = strip_subtitle

      @subtitle_to_html = @subtitle ? to_html(@subtitle) : nil
      @stripped_subtitle_to_html = @stripped_subtitle ? to_html(@stripped_subtitle).sub(/\A<p>(.*)<\/p>\z/, "\\1") : nil
      @body_to_html = to_html(@body)
    end

    def body
      @body.dup
    end

    def to_src
      r = ''
      r << "#{@subtitle}\n" if @subtitle
      r << @body
    end

    def html4( date, idx, opt )
      r = %Q[<div class="section">\n]
      r << do_html4( date, idx, opt )
      r << "</div>\n"
    end

    def do_html4( date, idx, opt )
      r = ''
      subtitle = BlueCloth.new(@subtitle).to_html
      subtitle.sub!(/<h(\d)/) { "<h#{$1.to_i + 2}" }
      subtitle.sub!(/<\/h(\d)/) { "</h#{$1.to_i + 2}" }
      subtitle = subtitle.sub(/(\[([^\[]+?)\])+/) {
        $&.gsub(/\[(.*?)\]/) {
          $1.split(/,/).collect {|c|
            %Q|<%= category_anchor("#{c}") %>|
          }.join
        }
      }
      subtitle.sub!(/<h3>/,%Q[<h3><a href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}#p#{'%02d' % idx}" %>">#{opt['section_anchor']}</a> ])
      if opt['anchor'] then
        subtitle.sub!(/<h3><a /,%Q[<h3><a name="p#{'%02d' % idx}" ])
      end
      if opt['multi_user'] and @author then
        subtitle.sub!(/<\/h3>/,%Q|[#{@author}]</h3>|)
      end
      r << subtitle
      body = BlueCloth.new(@body).to_html
      body.gsub!(/<h(\d)/) { "<h#{$1.to_i + 2}" }
      body.gsub!(/<\/h(\d)/) { "</h#{$1.to_i + 2}" }
      r << body
      r.gsub!(/\{\{(.+?)\}\}/) {
        "<%=#{$1}%>"
      }
      r
    end

    def chtml( date, idx, opt )
      r = ''
      r << BlueCloth.new(@subtitle).to_html
      r << BlueCloth.new(@body).to_html
      r.gsub!(/\{\{(.+?)\}\}/) {
        "<%=#{$1}%>"
      }
      r
    end

    def to_s
      to_src
    end

    private
    
    def to_html(string)
      parser = BlueCloth.new( string )
      r = parser.to_html
      r.gsub!(/\{\{(.+?)\}\}/) {
        "<%=#{$1}%>"
      }
      r
    end

    def get_categories
      return [] unless @subtitle
      cat = /(\[([^\[]+?)\])+/.match(@subtitle).to_a[0]
      return [] unless cat
      cat.scan(/\[(.*?)\]/).collect do |c|
        c[0].split(/,/)
      end.flatten
    end

    def strip_subtitle
      return nil unless @subtitle
      r = @subtitle.sub(/^#\s*((\\?\[[^\[]+?\]\\?)+\s+)?/,'')
      if r == ""
        nil
      else
        r
      end
    end
  end

  class MarkdownDiary
    include DiaryBase
    include CategorizableDiary

    def initialize( date, title, body, modified = Time::now )
      init_diary
      replace( date, title, body )
      @last_modified = modified
    end

    def style
      'Markdown'
    end

    def replace( date, title, body )
      set_date( date )
      set_title( title )
      @sections = []
      append( body )
    end

    def append( body, author = nil )
      section = nil
      body.each do |l|
        case l
        when /^\#[^\#]/
          @sections << MarkdownSection::new( section, author ) if section
          section = l
        else
          section = '' unless section
          section << l
        end
      end
      @sections << MarkdownSection::new( section, author ) if section
      @last_modified = Time::now
      self
    end

    def each_section
      @sections.each do |section|
        yield section
      end
    end

    def to_src
      r = ''
      each_section do |section|
        r << section.to_src
      end
      r
    end

    def to_html( opt, mode = :HTML )
      case mode
      when :CHTML
        to_chtml( opt )
      else
        to_html4( opt )
      end
    end

    def to_html4( opt )
      r = ''
      idx = 1
      each_section do |section|
        r << section.html4( date, idx, opt )
        idx += 1
      end
      r
    end

    def to_chtml( opt )
      r = ''
      idx = 1
      each_section do |section|
        r << section.chtml( date, idx, opt )
        idx += 1
      end
      r
    end

    def to_s
      "date=#{date.strftime('%Y%m%d')}, title=#{title}, body=[#{@sections.join('][')}]"
    end
  end
end
