# daily_theme.rb $Revision: 1.1 $
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL
#

if @mode != 'conf' then
   add_header_proc do
      if @conf.options.include?('daily_theme.list')
         theme_list = @conf.options['daily_theme.list'].split(/\n/)
      else
         theme_list = "default"
      end
      
      index = Time.now.yday % theme_list.size
      theme_name = theme_list[index].strip

      <<-HTML
      <link rel="stylesheet" href="theme/#{theme_name}/#{theme_name}.css" title="#{theme_name}" type="text/css" media="all">
      HTML
      
   end
end

add_conf_proc( 'daily_theme', @daily_theme_label, 'theme' ) do
   daily_theme_conf_proc
end
def daily_theme_conf_proc
   if @mode == 'saveconf' then
      if @cgi.params['daily_theme.list'] && @cgi.params['daily_theme.list'][0]
         @conf['daily_theme.list'] = @cgi.params['daily_theme.list'][0]
      else
         @conf['daily_theme.list'] = nil
      end
      
	end
   
   # initialize Theme list
   @conf['daily_theme.list'] = "default" unless @conf['daily_theme.list']
   
	result = <<-HTML
   <h3>#{@daily_theme_label}</h3>
   <p>#{@daily_theme_label_desc}</p>
   <p><textarea name="daily_theme.list" cols="70" rows="20">#{CGI::escapeHTML( @conf['daily_theme.list'] )}</textarea></p>
	HTML
end
