# nazo.rb $Revision: 1.5 $
#
# nazo: ジャンプ先のエレメントをハイライトする。
#       通称「謎JavaScript。最終形態」
#   パラメタ:
#     color:      ハイライトの文字色(省略時:白)
#     background: ハイライトの背景色(省略時:赤)
#
# See: http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?%A5%EA%A5%F3%A5%AF%B8%B5%A4%F2%A4%BF%A4%C9%A4%C3%A4%C6%A4%E2%A1%A2%A4%C9%A4%B3%A4%CE%CF%C3%C2%EA%A4%AB%A4%EF%A4%AB%A4%E9%A4%CA%A4%A4%A4%F3%A4%C7%A4%B9%A4%B1%A4%C9
#

def nazo( color = '#fff', background = '#f00' )
	<<-SCRIPT
		<script type="text/javascript"><!--
		var hiliteStyle = new Object();
		hiliteStyle.color = "#{color}";
		hiliteStyle.backgroundColor = "#{background}";
		
		var hiliteElem = null;
		var saveStyle = null;
		
		function hiliteElement(name)
		{
		  if( hiliteElem ){
		    for (var key in saveStyle){
		      hiliteElem.style[key] = saveStyle[key];
		    }
		    hiliteElem = null;
		  }
		
		  hiliteElem = getHiliteElement(name);
		  if ( !hiliteElem ) return;
		
		  saveStyle = new Object();
		  for (var key in hiliteStyle){
		    saveStyle[key] = hiliteElem.style[key];
		    hiliteElem.style[key] = hiliteStyle[key];
		  }
		}
		
		function getHiliteElement(name)
		{
		  for (i=0; i<document.anchors.length; ++i) {
		    var anchor = document.anchors[i];
		    if ( anchor.name == name ) {
		      var elem;
		      if ( anchor.parentElement ) {
		        elem = anchor.parentElement;
		      } else if ( anchor.parentNode ) {
		        elem = anchor.parentNode;
		      }
		      return elem;
		    }
		  }
		  return null;
		}
		
		if( document.location.hash ){
		  hiliteElement(document.location.hash.substr(1));
		}
		
		hereURL = document.location.href.split(/\#/)[0];
		for( var i = 0; i < document.links.length; i++ ){
		  if( hereURL == document.links[i].href.split(/\#/)[0] ){
		    document.links[i].onclick = handleLinkClick;
		  }
		}
		
		function handleLinkClick()
		{
		  hiliteElement(this.hash.substr(1));
		}
		// --></script>
	SCRIPT
end	
