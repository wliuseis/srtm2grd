# srtm2grd

Perl 5 scripts to obtain topography in GMT grdfile format from SRTM (v4.1) model in GeoTIFF format.

We provide 3 scripts:

```
srtm2grd_gmt4.pl  -- need GMT4 & GDAL installed
srtm2grd_gmt5.pl  -- need GMT5 & GDAL installed
srtm2grd_gmt6.pl  -- need GMT6 & GDAL installed
```

## Usage

To see the usage by:

`perl srtm2grd_gmt?.pl`

where ? can be 4, 5, or 6.

## Example

To obtain the topography of the region with longitude = 120~122 & latitude = 40~42,
and output to topo_out.grd:

`perl srtm2grd_gmt?.pl -Gtopo_out.grd -R120/122/40/42`

where ? can be 4, 5, or 6.

## Notes

These are still testing scripts. If you find any bugs, please mail to me.

## Log

Written by: Wei Liu

Contact: wliu92@mail.ustc.edu.cn

First published: 2021.01.07
