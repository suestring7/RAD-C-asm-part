#!/usr/bin/awk -f
##########
#The MIT License (MIT)
#
# Copyright (c) 2015 Aiden Lab
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
##########
# Deduping script, checks that positions are within wobble or not
# Juicer version 1.5
# Returns absolute value of v
function abs(v) {
	return v<0?-v:v;
}
# Examines loc1 and loc2 to see if they are within wobble1
# Examines loc3 and loc4 to see if they are within wobble2
# If both are within wobble limit, they are "tooclose" and are dups
function tooclose(loc1,loc2,loc3,loc4) {
	if (abs(loc1-loc2)<=wobble1 && abs(loc3-loc4)<=wobble2) {
		return 1;
	}
	else return 0;
}

# Executed once, before beginning the file read
BEGIN {
	i=0;
	si=0;
	xi=0;
	wobble1=4;
	wobble2=4;
	# names of output files
	# the variable "name" can be set via the -v flag
	dupname=name"dups.txt";
	nodupname=name"merged_nodups.txt";
}
# strand, chromosome, fragment match previous; first position (sorted) within wobble1

abs($3-p3)<=wobble1 && $1 == p1 && $2 == p2 && $4 == p4 && $5 == p5 && $6 == p6 && $8 == p8 {
	# add to array of potential duplicates
	line[i]=$0;
	pos1[i]=$3;
	pos2[i]=$7;
	i++;
}
$3!=p3{
	x[xi]=i;
	xi++;
}

# excede wobble1 or not a duplicate, one of the fields doesn't match
abs($3-pos1[x[si]])>wobble1 || $1!=p1 || $2!=p2 || $4!=p4 || $5!= p5 || $6!=p6 || $8!=p8	{# size of potential duplicate array is bigger than 2
	while (i > 1) {
		for (j=x[si]; j<x[si+1]; j++) {
			if (!(j in dups) ) {
				for (k=j+1; k<i; k++) {
					# check each item in array against all the rest 
					if (tooclose(pos1[j],pos1[k],pos2[j],pos2[k])) {
						 dups[k]++; #places a 1 at dups[k]
					}
				}
			}
		}
		# print dups out to dup file, non-dups out to non-dup file
		for (j=x[si]; j<i; j++) {
			if (j in dups) {
				print line[j] > dupname
			}	
			else {
				print line[j] > nodupname
			}
		}
	}
	# size of potential duplicate array is 1, by definition not a duplicate
	else if (i == 1) {
		print line[0] > nodupname;
	}
	si++;
	# reset all the potential duplicate array variables
	if(abs($3-p3)>wobble1){
	delete line;
	delete dups;
	delete pos1;
	delete pos2;
	delete x;
	si = 0;
	xi = 1;
	i = 1;
	x[0]=0;
	line[0]=$0;
	pos1[0]=$3;
	pos2[0]=$7;
	}
}

# always reset the fields we're checking against on each read 
{ p1=$1;p2=$2;p3=$3;p4=$4;p5=$5;p6=$6;p7=$7;p8=$8;}
END {
	if (i > 1) {
		# same code as above, just process final potential duplicate array
		for (j=0; j<i; j++) {
			# only consider reads that aren't already marked duplicate
			# (no daisy-chaining)
			if (!(j in dups) ) {
				for (k=j+1; k<i; k++) {					
					if (tooclose(pos1[j],pos1[k],pos2[j],pos2[k])) {
							dups[k]++;
					}
				}
			}
		}
		for (j=0; j<i; j++) {
			if (j in dups) {
				print line[j] > dupname
			}
			else {
				print line[j] > nodupname
			}
		}
	}
	else if (i == 1) {
		print line[0] > nodupname
	}
}
