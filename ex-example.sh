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

## REAL WORLD EXAMPLE ##

# Insert random string for validation purposes. If SQL returns nothing, this will force
# something in the file to continue validation checks. After checks this entry is removed
# from the file using 'ex'.

echo $RANDSTRING >> $OUTFILE;

# test OUTFILE to see if randstring is the only item
SRESULTS=$(head -1 $OUTFILE);
if [ "$SRESULTS" == "$RANDSTRING" ];
        then
                # do some logging/reporting here...
                /bin/ex +g/$RANDSTRING/d -cwq $OUTFILE;
                exit 0;
fi

# clean up RANDSTRING in file before manipulation continues.
/bin/ex +g/$RANDSTRING/d -cwq $OUTFILE;
