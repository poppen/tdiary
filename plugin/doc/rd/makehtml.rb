#!/usr/bin/ruby
#  makehtml.rb -- make html from rd
#
#  Copyright (C) 2001,2002 MUTOH Masao <mutoh@highway.ne.jp>
#  You may redistribute it and/or modify it under the same
#  license terms as Ruby.
#
# The original version of this file was distributed as 
# rd2html-ext-lib.rb version 0.1.2 
# by rubikitch <rubikitch@ruby-lang.org> under the same 
# license terms as Ruby.

if __FILE__ != $0
require 'rd/rd2html-lib'

module RD
  class YARDHTMLExtVisitor < RD2HTMLVisitor
    # must-have constants
    OUTPUT_SUFFIX = "html"
    INCLUDE_SUFFIX = ["html"]
    
    METACHAR = { "<" => "&lt;", ">" => "&gt;", "&" => "&amp;" }
    Delimiter = "\ca\ca"
    def html_body(contents)
      html = super
      a = html.split(Delimiter)
      a.each_with_index do |s, i|
        if i % 2 == 1
          meta_char_unescape!(s)
        end
      end
      a.join
    end
    
    def apply_to_Index(element, content)
      %Q[#{Delimiter}#{content}#{Delimiter}]
    end

    def meta_char_unescape!(str)
      str.gsub!(/(&lt;|&gt;|&amp;)/) {
        METACHAR.index($&)
      }
    end

    attr(:head, true)

    def apply_to_TextBlock(element, content) 
     if (element.parent.is_a?(ItemListItem) or
         element.parent.is_a?(EnumListItem) or
         element.parent.is_a?(MethodListItem))
       content = content.delete_if{|x| x == "\n"}.join("").gsub(/\n/, "<br />\n")
       content.chomp
     else
       content = content.delete_if{|x| x == "\n"}.join("").gsub(/\n/, "<br />\n")
       %Q[<p>#{content.chomp}</p>]
      end
    end

    def apply_to_Verbatim(element)
      if (element.parent.is_a?(ItemListItem) or
          element.parent.is_a?(EnumListItem) or
          element.parent.is_a?(MethodListItem))
        content = []
        element.each_line do |i|
          content.push("<br />" + apply_to_String(i).chomp)
        end
        content.join("").chomp
      else
        content = []
        element.each_line do |i|
          content.push(apply_to_String(i))
        end
        %Q[<pre>#{content.join("").chomp}</pre>]
      end
    end
  end
end
$Visitor_Class = RD::YARDHTMLExtVisitor
end

if __FILE__ == $0
  Dir.glob("*.rd").each do |file|
    name = File.basename(file, ".rd")
    
    print("#{name}.rd -> ../#{name}.html\n")
    result = open("|rd2 -r makehtml.rb --with-css='./doc.css' --html-title='#{name}' --html-charset=euc-jp #{name}.rd", "r").read
    result = result.gsub(/<body>/, %Q[
<body><p><a href="./index.html">[Back] </a>\n])
    file = open("../#{name}.html", "w")
    file.print(result)
    file.close
  end

  require 'makeindex.rb'
  print("\nMake Index\n")
  MakeIndex.new.execute
end

