#!/usr/bin/perl -w
#
# Needed:
#   gdal_translate, from GDAL
#   grdpaste, from GMT4
#   grdcut, from GMT4
#
# Notice:
#   make sure lon = [-180,180] & lat = [-60,60]!
#
# For more information by running this script with no inputs.
#

use Getopt::Std;

## directory of SRTM v4.1
$SRTM_DIR="/public/data/TopographyModels/SRTMv4.1/tiles/GeoTIFF";

sub Usage {
  print STDERR <<END;
$0 -- Get topography in GMT grdfile format from SRTM

Version: 1.0.0 (2021.01.07)
By Wei Liu

Usage: perl $0 -G<grdfile> -R<lon_min/lon_max/lat_min/lat_max>

  -G  <grdfile> specify the output GMT grdfile
  -R  specify the longitude and latitude ranges

Example:
  Get topography of the region with longitude = 120~122 &
  latitude = 40~42, and output to topo_out.grd:
    perl $0 -Gtopo_out.grd -R120/122/40/42

Notice:
  1) This script is suitable for GMT 4.
  2) GDAL >=3.2.1 is needed.
  3) We only deal with region where both the longitude and
     latitude ranges < 5 degrees. For region with larger
     size, ETOPO1 is enough.
  4) Make sure the longitude range is between -180 and 180,
     and the latitude range is between -60 and 60.
  5) This is still a testing script. If you find any bugs,
     please mail to: wliu92\@mail.ustc.edu.cn

END
exit(1)
}

if(@ARGV==0){
  Usage();
}

if(!getopts('G:R:') || !defined($opt_G) || !defined($opt_R)){
  print STDERR "Error in input arguments!\n";
  print STDERR "For more help by running: perl $0\n";
  exit(1);
}

$grd_topo=$opt_G;

($xmin,$xmax,$ymin,$ymax)=split('\/',$opt_R);

if(abs($xmin)>180 || abs($xmax)>180 || abs($ymin)>60 || abs($ymax)>60){
  print STDERR "Error in input ranges, check -R!\n";
  print STDERR "Make sure the longitude range is between -180 and 180, and the latitude range is between -60 and 60.\n";
  print STDERR "For more help by running: perl $0\n";
  exit(1);
}

print "\nInformation:\n";
print "  Output GMT grdfile: $grd_topo\n";
print "  Longitude range:    $xmin $xmax\n";
print "  Latitude range:     $ymin $ymax\n\n";

$srtm_topo="topo_main_srtm.grd";

if(($xmax-$xmin)<=5 && ($ymax-$ymin)<=5){
  print "Get topography from SRTM\n";
  &ReadSRTM($SRTM_DIR,$srtm_topo,$xmin,$xmax,$ymin,$ymax);
  system("grdcut $srtm_topo -G$grd_topo -R$xmin/$xmax/$ymin/$ymax");
  system("rm $srtm_topo");
}else{
  print "Large region, don\'t need SRTM, will exit.\nWe only deal with region where both the latitude and longitude ranges < 5 degrees.\n";
}


##### Subroutines #####

sub FindSRTM {
  my($MainDir,$lon,$lat)=@_;
  # Note: make sure $lon=[-180,180], $lat=[-60,60]!!!
  my $x=sprintf("%2.2d",int(($lon+180)/5.0)+1);
  my $y=sprintf("%2.2d",int((60-$lat)/5.0)+1);
  my $file="$MainDir/srtm"."_$x"."_$y".".tif";
  return $file;
}


sub TransSRTM {
  my($file1,$file2,$outfile)=@_;
  system("gdal_translate -of GMT $file1 tmp_srtm1.grd");
  system("gdal_translate -of GMT $file2 tmp_srtm2.grd");
  system("grdpaste tmp_srtm1.grd tmp_srtm2.grd -G$outfile -fg");
  system("rm tmp_srtm1.grd tmp_srtm1.grd.aux.xml");
  system("rm tmp_srtm2.grd tmp_srtm2.grd.aux.xml");
  return 1;
}


sub ReadSRTM {
  my($MainDir,$outfile,$lon1,$lon2,$lat1,$lat2)=@_;
  my $file_ld=&FindSRTM($MainDir,$lon1,$lat1);
  my $file_lu=&FindSRTM($MainDir,$lon1,$lat2);
  my $file_ru=&FindSRTM($MainDir,$lon2,$lat2);
  my $file_rd=&FindSRTM($MainDir,$lon2,$lat1);
  print "Read GeoTIFF from SRTM\n";
  print "  Left down:   $file_ld\n";
  print "  Left up:     $file_lu\n";
  print "  Right down:  $file_rd\n";
  print "  Right up:    $file_ru\n";
  if($file_lu ne $file_ld){
    &TransSRTM($file_lu,$file_ld,"tmp_left.grd");
    if($file_rd ne $file_ld){
      &TransSRTM($file_ru,$file_rd,"tmp_right.grd");
      system("grdpaste tmp_left.grd tmp_right.grd -G$outfile -fg");
      system("rm tmp_left.grd tmp_right.grd");
      print "  Total parts: 4\n";
    }else{
      system("mv tmp_left.grd $outfile");
      print "  Total parts: 2 (up & down)\n";
    }
  }else{
    if($file_rd ne $file_ld){
      &TransSRTM($file_rd,$file_ld,$outfile);
      print "  Total parts: 2 (left & right)\n";
    }else{
      system("gdal_translate -of GMT $file_ld $outfile");
      system("rm $outfile.aux.xml");
      print "  Total part: 1\n";
    }
  }
  return 1;
}
