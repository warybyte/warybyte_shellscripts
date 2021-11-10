#!/bin/bash
report=server_cron_report_name.txt
for servers in $(echo SERVER_ARRAY{1..4}.DOMAIN); 
do 
  echo $servers >> $report; 
  ssh $servers 'for users in $(ls /home/); do echo "$users: $(sudo crontab -l -u $users > /dev/null 2>&1 && sudo crontab -l -u $users)"; done' >> $report; 
done
