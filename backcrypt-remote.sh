######  
# This script assumes the existance of a remote encrypted file share which is locked by a key. They key 
# is retained locally and only pushed to the remote system when needed. It also assumes you have privs
# control of remote systems since mount FS depends on privilaged access.
######
#!/bin/bash
#
# push local key to remote machine
#
scp disk_secret_key youruser@ec2-20-20-20-20.us-west-2.compute.amazonaws.com:/home/youruser;
#
# SSH to remote machine and set up encrypted filesystem, then remove key
#
ssh -t youruser@ec2-20-20-20-20.us-west-2.compute.amazonaws.com '\
  sudo mv disk_secret_key /root/;\
  sudo chown root:root /root/disk_secret_key;\
  sudo cryptsetup -v luksOpen /decryptfs decryptfs --key-file=/root/disk_secret_key;\
  sudo mount /dev/mapper/decryptfs /decryptfs;\
  sudo chown -R youruser:youruser /decryptfs;\
  sudo rm -f /root/disk_secret_key';
#
# Push data to remote encrypted directory
#
scp -r /BACKUPDATA youruser@ec2-20-20-20-20.us-west-2.compute.amazonaws.com:/decryptfs;
#
# Close remote encrypted volume
#
ssh -t youruser@ec2-20-20-20-20.us-west-2.compute.amazonaws.com '\
sudo umount /decryptfs;\
sudo cryptsetup -v luksClose decryptfs;'
#
# OPTIONAL: Email results...assumes email...
#
RESULT=$?;
if [ $RESULT -eq 0 ]; then
        mail -s "Data backup to encrypted system completed successfully" youruser@email.domain < /dev/null
else
        mail -s "Data backup to encrypted system failed. See logs." youruser@email.domain < /dev/null
fi



