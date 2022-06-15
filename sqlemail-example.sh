#!/bin/bash
# Example using SQLPlus, bash, and some mailx...pulling schedule data from a database
# DEFINE GENERAL VARS...EMAIL VARS DEFINED FURTHER DOWN
ORACLE_HOME="/u01/app/oracle/product/12.2.0/client_1";
SQL_PLUS="$ORACLE_HOME/bin/";
OUTFILE=/tmp/schedule_monitor/sched_results.txt;
SACCOUNT="<USERACCOUNT>";
SPASS="<PASSWORD>";
RECORDCOUNT=1;
NOW=`date +%m-%d-%y" "%H:%M:%S`;
LOGFILE=/tmp/schedule_monitor/sched_log.txt;
ENDDATE=$(date --date="30 days" +%m-%d-%Y)

# BUILD ENV
export ORACLE_HOME;
export SQL_PLUS;

$SQL_PLUS/sqlplus "$SACCOUNT/$SPASS@<INSERT DB>" << END_SQL
@sched_pull.sql $OUTFILE
END_SQL

if test $? -ne 0
then
	echo "ERROR OCCURRED WITH SQL CALL" >> $LOGFILE;
	exit 1;
fi

# Insert random string for validation purposes. If SQL returns nothing, this will force
# something in the file to continue validation checks. After checks this entry is removed
# from the file using 'ex'.

RANDSTRING="1zbwr4AAlq";
echo $RANDSTRING >> $OUTFILE;

# after injecting randstring into OUTFILE, see if it appended to the top...
SRESULTS=$(head -1 $OUTFILE);
if [ "$SRESULTS" == "$RANDSTRING" ];
        then
                echo "${NOW} - No record found." >> $LOGFILE;
                /bin/ex +g/$RANDSTRING/d -cwq $OUTFILE;
                exit 1;
fi

# clean up RANDSTRING in file before manipulation continues.
/bin/ex +g/$RANDSTRING/d -cwq $OUTFILE;

# if OUTFILE contains real data, this loop will catch each item and fire emails 
for SRESULTS in $(cat $OUTFILE | sed -r 's/\s+/,/g'); 
do
	# ----- Variables specific to email ----- #
	MAILLIST='dev@ticketing.lcl';
	SUBJECT="TEST Schedule Ending: $ENDDATE";
	MODSCHED=$(echo $SRESULTS | awk -F ',' '{print $3"\ /\ "$2}');
	BODY="
	This is the email body
	";

	# fire email
	echo "$BODY" | mailx -r "admins@domain.lcl" -s "$SUBJECT" "$MAILLIST";

	# validate email processed	
	if test $? -eq 1
	then
        	echo "${NOW} - Problem mailing file" >> $LOGFILE;
        	exit 1;
	else
    		echo "${NOW} - Email sent" >> $LOGFILE;
    		echo "$SRESULTS" >> $LOGFILE;
	fi

	echo "--------------------------------------------------------------" >> $LOGFILE;
	echo "                                                    " >> $LOGFILE;
	sleep 3;
	RECORDCOUNT=$(( $RECORDCOUNT+1 ));
done
