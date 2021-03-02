# 03/02/2021
#
# Add .ssh/config entries easily!
#
# Directions: ~/sshconfig-add.sh <system-fqdn>
#
#!/bin/bash
outp="/home/<YOURUSER>/.ssh/config";
defport=<SSH PORT> #if different from default...remake this as $2 input option?
you=<YOURUSER>
for sysname in $(echo $1)
do
  digout=$(dig +short $sysname);
  echo "Host $sysname" >> $outp;
  echo "HostName $digout" >> $outp;
  echo "User $you" >> $outp;
  echo "Port $defport" >> $outp; 
  echo "" >> $outp;
  echo "" >> $outp;
  echo "$1 added to SSH Config" >> tmp.file;
done
echo "Process completed:";
cat tmp.file;
# clean up;
rm tmp.file;
  
