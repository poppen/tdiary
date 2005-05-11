require 'rbconfig'
require 'ftools'

DIR='./lib/'

FILES=[
    'rjpeg.rb',
    'rexif_gps.rb',
    'wgs2tky.rb'
]

File::makedirs(Config::CONFIG['sitelibdir'])
FILES.each{|f|
    File::install("#{DIR}/#{f}",
		  "#{Config::CONFIG['sitelibdir']}/#{f}",0644,true)
}
