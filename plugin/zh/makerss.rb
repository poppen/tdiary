# makerss.rb English resources
@makerss_encode = 'UTF-8'
@makerss_encoder = Proc::new {|s| s }

def makerss_tsukkomi_label( id )
	"TSUKKOMI to #{id[0,4]}-#{id[4,2]}-#{id[6,2]}[#{id[9,2].sub( /^0/, '' )}]"
end
