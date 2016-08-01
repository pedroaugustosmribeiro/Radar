#!/bin/sh
sed 's/,,/,/' $(grep -lR 'PLU(mm)' CSV)|cut -d, -f1,2,3|sed -e '/Posto/d' -e 's/,/ /g' >rain.dat

#Written by Pedro Augusto in 2016
#Explanation:
#
#first sed substitutes two commas by one in the header of all the files
# listed by the inner command grep, which searches for files that have PLU(mm) string
# in their contents and are located in all subdirectories of the folder CSV.
# PLU(mm) means precipitation measurement
#
#the command cut in the middle of the pipe selects just the first 3 columns of the data (Station Code,Time and PLU measurements)
#
#the last sed removes the header lines and substitutes commas by white spaces, as IDL likes.
#
#Finnally, the result is written into one big concateneted and filtered data file raind.dat