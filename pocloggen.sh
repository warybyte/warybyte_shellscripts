#!/bin/bash
# ---------------------------------------------------------------------------------------------#
# Generate years of log files for PoC, including consistent timestamps                         #
# ./pocloggen.sh <path/to/logs>								       #
# Author:    Warybyte			                                                       #
# Last Edit: 20210916                                                                          #
# ---------------------------------------------------------------------------------------------#

# define the vars
# example: '/var/log/test'

logpath=$1

# generate files named by time-stamp (yyyymmdd_hhmm_ss.log)
# example: 20200101_1200_00.log ... 20211231_1200_00.log

for logfile in $(echo {2020..2021}{01..12}{01..31}_1200_00.log)
do
	echo "Creating $logfile";
	# stuffng non-existent file with data creates it by default...
	charcount=$(cat /dev/urandom | tr -dc [:digit:] | fold -2 | head -1);
	cat /dev/urandom | tr -dc [:alnum:] | fold -$charcount | head -1 >> $logpath/$logfile;
done

# update log time-stamps and purge files with invalid dates
# example: 20200230, 20200231, 20200431, etc...

for logfile in $(ls -1 $logpath/)
do
	retimes=$(echo $logfile | awk -F '_' '{print $1$2"."$3}' | awk -F '.' '{print $1"."$2}')
	echo "Re-timing or purging PoC log file";
	touch -t $retimes $logpath/$logfile || rm $logpath/$logfile;
done
