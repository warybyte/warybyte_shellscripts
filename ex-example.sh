#!/bin/bash

#############################################################################
##
## Ex is a Linux CLI text editing tool. Unlike Sed, it doesn't modify text ##
## in a stream, meaning you don't have to pipe it out. Sed has an in-place ##
## function for this, but it's a feature, not the standard.                ##
##                                                                         ##
#############################################################################
OUTFILE=text.txt;
RANDSTRING="thisisarandomstring";

# Below locates and destroys the random string from the file without streaming
/bin/ex +g/$RANDSTRING/d -cwq $OUTFILE;
