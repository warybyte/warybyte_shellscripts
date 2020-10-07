#!/bin/bash
#
# Looking for a quick and dirty way to randomize your passwords on 100s of Linux servers? Here ya go...
#
# rhel6
for j in $(cat servername.list); 
do 
  i=$(openssl rand -base64 12 | tr -dc [:alnum:]);  
  echo "Root passwd for $j will be $i"; 
  ssh -t $j \"echo -e \"$i\n$i\" | sudo passwd root\"; 
  echo; 
done
#
# rhel5
#
for j in $(cat servername.list); 
do 
  i=$(openssl rand -base64 12 | tr -dc [:alnum:]); 
  echo "Root passwd for $j will be $i"; 
  ssh -t $j \"echo \"$i\"\ \|\ sudo passwd --stdin root\"; 
done
