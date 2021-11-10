#!/bin/bash
report=<YOUR_LOCAL_REPORT>; 
for servers in $(echo $1); 
do 
	echo $servers >> $report; 
	ssh -t $servers '
	for users in $(cut -d ":" -f1 /etc/passwd); 
	do 
		echo "$users: $(sudo crontab -l -u $users > /dev/null 2>&1 && sudo crontab -l -u $users)"; 
	done
       ' >> $report; 
done
