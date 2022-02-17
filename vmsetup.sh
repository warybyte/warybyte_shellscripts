#!/bin/bash
# Author:
# - Joshua McDill

# Description:
# - script that sets up my Linux virtual machine (VM) for daily work

# Automates the following: 
# - boots VM
# - establishes SSH connection
# - maps a fileshare between local and VM
# - initiates VPN authentication process

# Assumes the following:
# - root access to mount fileshare
# - installation of SSHFS package (used for the SFTP mapping)
# - use of Gnome-Boxes for VM
# - use of Cisco Anyconnect VPN client
# - SSH connection via shared keys

# -----------------------------------------
# boot VM
# note: gnome-boxes is assumed
# -----------------------------------------
VMPRIME=$(virsh list --state-shutoff --name)
VMHOSTNAME=NNN.NNN.NNN.HHH
VMFILEPATH=/home/user/vmdump
virsh start $VMPRIME
statu=0; 
remu=20;  
echo "Waiting for VM to load...";     	
while [ $statu -le $remu ]; 
do
  nc -z $VMHOSTNAME 22;
  if [[ $? -eq 0 ]]
  then
	statu=20;
	remu=0;
	echo "[$(printf %"$statu"s | tr " " "|")$(printf %"$remu"s | tr " " " ")]";
	echo "VM lauch complete!"
	break;
  else
  	echo -en "[$(printf %"$statu"s | tr " " "|")$(printf %"$remu"s | tr " " " ")] \r"; 
  	((statu++));
  	((remu--));
  fi	  
done
sleep 3;

# ----------------------------------------
# connect SSH
# note: this has to be set before the VPN
# ----------------------------------------
echo "Opening second terminal for SSH connection...";
sleep 4;
gnome-terminal --tab -- ssh $VMHOSTNAME;

# ----------------------------------------
# mount share
# note: sudo because you are mounting an FS. 
# ----------------------------------------
echo "Mounting shared drive.";
echo "Please enter your local workstation password..."
sudo sshfs -o allow_other,default_permissions,IdentityFile=/home/user/.ssh/id_rsa tron@$VMHOSTNAME:./vmdump/ $VMFILEPATH;
echo "Mounting complete...";
df -h | grep vmdump;
sleep 4;

# ----------------------------------------
# connect VPN
# note: -t flag is necessary for setup to 
# avoid typing password in plain text
# ----------------------------------------
echo "Connecting to VPN on VM. Please follow directions...";
sleep 3;
ssh -t $VMHOSTNAME '/opt/cisco/anyconnect/bin/vpn connect <INSERT_YOUR_VPN/INSERT_YOUR_VPN_GROUP>';
echo "VM setup completed. Please change tabs to access.";
echo "Goodbye!"
echo "
To exit VPN on VM: /opt/cisco/anyconnect/bin/vpn disconnect
To check VPN state: /opt/cisco/anyconnect/bin/vpn state
"
