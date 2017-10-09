#!/bin/sh
pluv_folder=/home/pedro/dados/data_dir_starnet/CTH/Pluviometro
grep -lR 'PLU(mm)' $pluv_folder|xargs sed 's/,,/,/'|cut -d, -f1,2,3 -s|sed -e '/Posto/d' -e 's/,/ /g' >rain_temp.dat
awk -F" " '$1!=""&&$2!=""&&$3!=""' rain_temp.dat>rain.dat
rm rain_temp.dat
#Written by Pedro Augusto in 2016
#Explanation:
#
#first sed substitutes two commas by one in the header of all the files
# listed by the previous command grep, which searches for files that have PLU(mm) string
# in their contents and are located in all subdirectories of the folder CSV, passing to sed by xargs.
# PLU(mm) means precipitation measurement.
#
#the command cut in the middle of the pipe selects just the first 3 columns of the data (Station Code,Time and PLU measurements)
#
#the last sed removes the header lines and substitutes commas by white spaces, as IDL likes.
#
#Then the result is written into one big concateneted and pre-filtered temporary data file rain_temp.dat
#Finally, awk removes missing data lines (lines that don't have the 3rd collumn PLU) and writes to the final data file rain.dat.
#
#The last line just removes the temporary file
