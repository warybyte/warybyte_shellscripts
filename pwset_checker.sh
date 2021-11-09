#!/bin/bash
# This script scrapes the /etc/shadow file to determine whether accounts have a password set or not
for j in $(sudo cat /etc/shadow); 
do 
	u=$(echo $j | awk -F ':' '{print $1}'); 
	p=$(echo $j | awk -F ':' '{print $2}'); 
	if test -z "$p"; 
		then p="empty"; 
		else p="set"; 
	fi; 
	echo $u,$p >> $(uname -n)_shadowreport.txt; 
done
