Hi, these are the scripts I wrote to process the data into more usable forms. 

Some are general utilities, some are specifically for processing this dataset. 
The bulk processing files are in the bulk/ directory to keep them distinct from the utilities.


Utililies:

asc-join file1 file2 file3... outfile
- combines several .asc files into a single larger file.

asc-merge file1 file2 file3... outfile
- merges .asc files over the top of each other but does not alter xll,yll,nrows or ncols

asc-to-png infile outfile
- converts a .asc to .png using grey scale 0..255 for height above sealevel. Levels above and below are truncated. Undefined values are red.


Order of bulk processing from Channel Coast Observatory provided data:

copy-stuff -- copies files into logical directories. Overlapping files are called x.1 x.2, later scripts combine them
convert-all-ecw-to-jpg -- convert all the ecw files to jpg format
combine-overlapping-asc-files -- combines .asc.1 .asc.2 files into a single .asc file
combine-overlapping-jpg-files -- combines .jpg.1 .jpg.2 files into a single .jpg file
combine-500m-ascii-files -- combines 500m ne/se/sw/nw files into 1000m flles.
convert-all-asc-to-png -- converts all .asc files to greyscale .png files
create-thumbnails -- creates a thumbnail directory for every jpg and png file and creates an HTML view of them in a grid.
