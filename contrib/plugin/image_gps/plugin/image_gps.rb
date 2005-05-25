#

require 'wgs2tky'

def image( id, alt = 'image', thumbnail = nil, size = nil, place = 'photo' )
	if @conf.secure then
		image = "#{@image_date}_#{id}.jpg"
		image_t = "#{@image_date}_#{thumbnail}.jpg" if thumbnail
	else
		image = image_list( @image_date )[id.to_i]
		image_t = image_list( @image_date )[thumbnail.to_i] if thumbnail
	end
	if size then
		if size.kind_of?(Array)
			size = " width=\"#{size[0]}\" height=\"#{size[1]}\""
			
		else
			size = " width=\"#{size.to_i}\""
		end
	else
		size = ""
	end
	
	eznavi = 'http://walk.eznavi.jp'
	mapion = 'http://www.mapion.co.jp'
	( detum,nl,el ) = gps_info("#{@image_dir}/#{image}")
	
	if thumbnail then
		%Q[<a href="#{@image_url}/#{image}"><img class="#{place}" src="#{@image_url}/#{image_t}" alt="#{alt}" title="#{alt}"#{size}></a>]
	else
		unless el.nil?
			if @conf.mobile_agent?
				lat = "#{sprintf("%d.%d.%.2f",*nl)}"
				lon = "#{sprintf("%d.%d.%.2f",*el)}"
				%Q[<a href="#{eznavi}/map?detum=1&amp;unit=0&amp;lat=+#{lat}&amp;lon=+#{lon}"><img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}"#{size}></a>]
			else
				Wgs2Tky.conv!(nl,el) if detum == 'WGS-84'
				lat ="#{sprintf("%d.%d.%.3f",*nl)}"
				lon ="#{sprintf("%d.%d.%.3f",*el)}"
				%Q[<a href="#{mapion}/c/f?el=#{lon}&amp;nl=#{lat}&amp;scl=10000&amp;pnf=1&amp;uc=1&amp;grp=all&amp;size=500,500"><img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}" #{size}></a>]
			end
		else
			%Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}"#{size}>]
		end
	end
end

require 'rexif_gps'

Jpeg.use_class_for(Jpeg::Segment::APP1,Exif)

def gps_info(fname)
	fname.untaint
	exif = Jpeg::open(fname,Jpeg::PARSE_HEADER_ONLY).app1
	
	return nil unless(exif.is_exif?)
	return nil unless(exif.ifd0.gpsifd)
	
	gps = exif.ifd0.gpsifd
	
	if( gps.latitude_ref.value=="N" && gps.longitude_ref.value=="E" && (gps.map_datum.value=="TOKYO"||gps.map_datum.value=="WGS-84"))
		return gps.map_datum.value,gps.latitude.value,gps.longitude.value
#    return "#{sprintf("%d.%d.%.2f",*latitude)}", "#{sprintf("%d.%d.%.2f",*longitude)}"
	end
rescue
end
