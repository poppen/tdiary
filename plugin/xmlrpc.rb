# xmlrpc.rb: $Revision: 1.1 $
#
# XML-RPC API
#
# Copyright (c) 2004 MoonWolf <moonwolf@moonwolf.com>
# Distributed under the GPL
#

add_header_proc do
  %Q!\t<link rel="EditURI" type="application/rsd+xml" title="RSD" href="#{@conf.base_url}rsd.xml" />\n!
end

add_conf_proc('XMLRPC', 'XML-RPC API') do
	saveconf_xmlrpc
	xmlrpc_init

	<<-HTML
	<h3 class="subtitle">#{label_xmlrpc_url}</h3>
	<p><input type="text" name="xmlrpc.url" value="#{@conf['xmlrpc.url']}" size="100"></p>
	<h3 class="subtitle">#{label_xmlrpc_blogid}</h3>
	<p><input type="text" name="xmlrpc.blogid" value="#{@conf['xmlrpc.blogid']}" size="20"></p>
	<h3 class="subtitle">#{label_xmlrpc_username}</h3>
	<p><input type="text" name="xmlrpc.username" value="#{@conf['xmlrpc.username']}" size="20"></p>
	<h3 class="subtitle">#{label_xmlrpc_password}</h3>
	<p><input type="password" name="xmlrpc.password" value="#{@conf['xmlrpc.password']}" size="20"></p>
	<h3 class="subtitle">#{label_xmlrpc_lastname}</h3>
	<p><input type="text" name="xmlrpc.label_xmlrpc_lastname" value="#{@conf['xmlrpc.lastname']}" size="20"></p>
	<h3 class="subtitle">#{label_xmlrpc_firstname}</h3>
	<p><input type="text" name="xmlrpc.firstname" value="#{@conf['xmlrpc.firstname']}" size="20"></p>
	<h3 class="subtitle">#{label_xmlrpc_userid}</h3>
	<p><input type="text" name="xmlrpc.userid" value="#{@conf['xmlrpc.userid']}" size="20"></p>
	HTML
end

#
# for conf_proc
#
def xmlrpc_init
  @conf['xmlrpc.url']       ||= @conf.base_url + 'xmlrpc.rb'
  @conf['xmlrpc.blogid']    ||= 'devlog'
  @conf['xmlrpc.username']  ||= 'default'
  @conf['xmlrpc.password']  ||= ''
  @conf['xmlrpc.lastname']  ||= ''
  @conf['xmlrpc.firstname'] ||= 'default'
  @conf['xmlrpc.userid']    ||= 'default'
end

def saveconf_xmlrpc
  if @mode == 'saveconf' then
    @conf['xmlrpc.url']       = @cgi.params['xmlrpc.url'][0] || 'xmlrpc.rb'
    @conf['xmlrpc.blogid']    = @cgi.params['xmlrpc.blogid'][0] || 'default'
    @conf['xmlrpc.username']  = @cgi.params['xmlrpc.username'][0] || 'default'
    @conf['xmlrpc.password']  = @cgi.params['xmlrpc.password'][0] || ''
    @conf['xmlrpc.lastname']  = @cgi.params['xmlrpc.lastname'][0] || ''
    @conf['xmlrpc.firstname'] = @cgi.params['xmlrpc.firstname'][0] || 'default'
    @conf['xmlrpc.userid']    = @cgi.params['xmlrpc.userid'][0] || 'default'
    open('rsd.xml','w') {|f|
      f.write <<-EOS
      <rsd version="1.0">
        <service>
          <engineName>tDiary</engineName>
          <engineLink>http://www.tdiary.org/</engineLink>
          <homePageLink>#{@conf.base_url}</homePageLink>
          <apis>
          <api name="MetaWeblog" preferred="true" apiLink="#{@conf['xmlrpc.url']}" blogID="#{@conf['xmlrpc.blogid']}"/>
          <api name="Blogger" preferred="false" apiLink="#{@conf['xmlrpc.url']}" blogID="#{@conf['xmlrpc.blogid']}"/>
          </apis>
        </service>
      </rsd>
      EOS
    }
  end
end
