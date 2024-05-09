#!/bin/bash
# -------------------------------------------------------------------------------------
# A fun bash exercise that creates a random DNA sequence of adenine, guanine, cytosine, 
# and thymine pairs.
# 
# Initialized: 05.02.2017
# Last Edit: 11.22.2023
# 
# Author: Joshua McDill
# --------------------------------------------------------------------------------------
#
#	adenine : yellow
#	guanine : red
#	cytosine : orange
#	thymine : green
#
# Example string...
#
#            /-cg-/           
#        /----ta----/        
#      /-------cg-------/     
#   /----------gc----------/  
# /------------gc------------/
#  /----------gc----------/ 
#     /-------cg-------/    
#        /----gc----/       
#           /-at-/          
#            /-at-/           
#         /----at----/        
#      /-------ta-------/     
#   /----------gc----------/ 
# ...

# Define some pretty colors...

IFS='%';
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
CYAN="\033[36m"
NORMAL="\033[0;39m"

seqlength=3;
ct=0;

# Start building the framework, using sequences of dashes to visualize a double helix strand

while [[ $ct < $seqlength ]];
do
dash1="           /-";
dash2="        /----";
dash3="     /-------";
dash4="  /----------";
dash5="/------------";
dash9="          /-";
dash8="       /----";
dash7="    /-------";
dash6=" /----------";

for fill in $dash{1..9};
   do
	# Create seed string 'agct' from which we'll randomly select a starting nucleotide base.
	# Once a base is set, a compatible second nucleotide is selected to form the pair, then
        # the sequence continues for x3 rotations.

	seqoption="agct"
	seqtop=$(echo "${seqoption:$(( RANDOM % ${#seqoption} )):1}")
	if [ "$seqtop" = "g" ]; then
       		seqtail=c;
		topcolor=$RED
		tailcolor=$CYAN
	elif [ "$seqtop" = "a" ]; then
       		seqtail=t;
		topcolor=$YELLOW
		tailcolor=$GREEN
	elif [ "$seqtop" = "c" ] ; then
       		seqtail=g;
		topcolor=$CYAN
		tailcolor=$RED
	elif [ "$seqtop" = "t" ]; then
       		seqtail=a;
		topcolor=$GREEN
		tailcolor=$YELLOW
	else
       		echo "Something went terribly wrong in the lab..."
	fi
	echo -e $NORMAL$topcolor$fill$seqtop$tailcolor$(echo $fill$seqtail | rev)$NORMAL;
   done
ct=$[$ct+1];	 
done
