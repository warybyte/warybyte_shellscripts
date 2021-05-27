# Purpose:
# I wanted a faster way to add new servers to my SSH config file...
#
# Directions:
# 
# ./sshconf-add.sh <servername>
# 
# Alt Directions if you use Bashrc alias...highly encouraged :)
# 
# sshconfadd <servername>
#
# Dependencies:
# - Accurate DNS records
# - Ability to modify script files
# - Desire to automate ALL THE THINGS!
#
# Ideas:
# - Make 'defport' and 'defuser' $2 and $3 variables you can define them at runtime vs. editing the config
# 
# ./sshconf-add.sh <servername> <username> <sshport>
# 
# This would be helpful for admins working in multiple environments under different usernames, ports, etc...
#
#!/bin/bash
outfile="~/.ssh/config";
sysname=$1;
defport=<INSERT PORT>;
defuser=<INSERT USERNAME>;

# get IP via DNS
digout=$(dig +short $sysname);

echo "Host $sysname" >> $outfile;
echo "HostName $digout" >> $outfile;
echo "User $defuser" >> $outfile;
echo "Port $defport" >> $outfile;
echo "" >> $outfile;

# comment tail to silence verbose log output
tail -5 $outfile;

# Results
echo "Completed: $1 added to ssh config";
