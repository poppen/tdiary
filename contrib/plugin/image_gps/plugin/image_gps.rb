#

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
	
	mapion = 'http://www.mapion.co.jp'
	( nl,el ) = gps_info("#{@image_dir}/#{image}")
	
	if thumbnail then
	   	%Q[<a href="#{@image_url}/#{image}"><img class="#{place}" src="#{@image_url}/#{image_t}" alt="#{alt}" title="#{alt}"#{size}></a>]
	else
		unless(el.nil?)
			%Q[<a href="#{mapion}/c/f?el=#{el}&amp;scl=70000&amp;pnf=1&amp;uc=1&amp;grp=all&amp;nl=#{nl}&amp;size=500,500"><img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}"#{size}></a>]
		else
			%Q[<img class="#{place}" src="#{@image_url}/#{image}" alt="#{alt}" title="#{alt}"#{size}>]
		end
	end
end

require 'rexif_gps'
require 'wgs2tky'

Jpeg.use_class_for(Jpeg::Segment::APP1,Exif)

def gps_info(fname)
	fname.untaint
	exif = Jpeg::open(fname,Jpeg::PARSE_HEADER_ONLY).app1
	
	return nil unless(exif.is_exif?)
	return nil unless(exif.ifd0.gpsifd)
	
	gps = exif.ifd0.gpsifd

	if(	gps.latitude_ref.value=="N"	&&
		gps.longitude_ref.value=="E"	&&
		(gps.map_datum.value=="TOKYO"	||
		 gps.map_datum.value=="WGS-84"))
				
		latitude = gps.latitude.value
		longitude = gps.longitude.value
				
		if(gps.map_datum.value=="WGS-84")
			Wgs2Tky.conv!(latitude,longitude)
		end
		return "#{sprintf("%d/%d/%.3f",*latitude)}", "#{sprintf("%d/%d/%.3f",*longitude)}"
	end
rescue
end
