#!/bin/bash
######################################################
## Master process for gather linux admin data...    ##
######################################################
# Last Modified: June 30, 2021
# Author: Joshua McDill (jwmcdill)
#
# Steps:
# 0. build small client script for generating report
# 1. loop through list of targets
# 2. scp client to targets
# 3. ssh targets and execute client
# 4. scp reports from target
# 5. ssh targets to clip reports and client
#
######################################################
## Are we running this correctly?                   ##
######################################################
if [ -z "$1" ] || [ -z "$2" ]
then
	echo "Mmmm...are we running this correctly?";
	echo "./script <target> <app>";
	echo "Example:";
	echo "./admin-repgen-v4.sh <THOST> <ENV>";
	exit 0;
fi
######################################################
## Build client script...aka escape room...         ##
######################################################
client_script="admin-check.sh";
echo "#!/bin/bash" >> $client_script;
echo "for j in \$(grep wheel /etc/group | awk -F ':' '{print \$4}' | sed s/\",\"/\" \"/g);" >> $client_script;
echo "do" >> $client_script;
echo "	echo \"\$j,admin,\$HOSTNAME\" >> \$HOSTNAME-admin.report;" >> $client_script;
echo "done" >> $client_script;
######################################################
## Send pay load to target, then clean up...        ##
######################################################
masterreport="$2-report-$(date +%m%d%y).csv";

for j in $(echo $1);
do
	echo "Running $j";
	scp admin-check.sh $j:.;
	ssh $j 'chmod +x admin-check.sh; ~/admin-check.sh';
	scp -P555 $j:./$j-admin.report .;
	ssh $j 'rm -f $HOSTNAME-admin.report admin-check.sh';
	cat $j-admin.report >> $masterreport || echo "Error reporting $j" >> $masterreport;
	rm -f $j-admin.report;
	rm -f admin-check.sh;
done
