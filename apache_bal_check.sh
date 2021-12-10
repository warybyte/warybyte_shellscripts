#
# Dynamically enumerate and test your balancer connections within all your Apache config files.
# Requires: grep, sed, awk, cut, and nc
#

#!/bin/bash
# Dynamically enumerate your web configs (in case you have MANY) and carve out any balancer nodes you have
for WEBENV in $(grep BalancerMember /etc/httpd/<YOURENV>.d/* | grep -v "#" | awk -F ' ' '{print $1}' | cut -d ":" -f1 | sort -u); 
do 
	
  echo $WEBENV; # this is more debugging than anything so I know where I am within the loops... 
  
	for WEBBAL in $(grep BalancerMember $WEBENV | awk -F '/' '{print $3}' | awk -F ' ' '{print $1}' | sort -u); 
	do
		# Uses netcat to test the connection between proxy and remote webapp, printing the results. Note: I'm not error handling here.
		# <WEBAPP>:<PORT> <STATUS>. 0 means good connection. 1 means failed connection. 
		
    # slightly more complex one-liner version below
    # echo $WEBBAL $(nc -z $(echo $WEBBAL | cut -d ":" -f1) $(echo $WEBBAL | cut -d ":" -f2); WEBSTT=$?; echo $WEBSTT);
    
        WEBAPP=$(echo $WEBBAL | cut -d ":" -f1);
        WEBPRT=$(echo $WEBBAL | cut -d ":" -f2);
        
		# do the network check...this doesn't have the be nc, I just find nc handy.
        
        nc -z $WEBAPP $WEBPRT;

    # assign value of nc PID result [0 or 1] to WEBSTT var
    
        WEBSTT=$?;
    
    # report
    
        echo $WEBBAL $WEBSTT;
 
	done; 
done
