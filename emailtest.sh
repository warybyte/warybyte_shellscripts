#!/bin/bash
MAILLIST="<EMAIL ADDRESS/GROUP>";
SUBJECT="<SUBJECT>";
PERIOD=$(date +%B" "%Y)
BODY="
Enterprise Application Engineering Team:

Please schedule downtime for $PERIOD Linux patching. 

Link here: https://warybyte.ticketing.lcl/Console
";

echo "$BODY" | mailx -r "dev@warybyte.com" -s "$SUBJECT" $MAILLIST

if test $? -eq 1
then
    logger "Downtime_Reminder - Error - Problem with transmission"
    exit 1
else
    logger "Downtime_Reminder - Success - Transmission successful"
fi
exit 0
