#!/bin/bash
#
# A little script to list which block devices are available in RedHat for partitions.
# Be sure to run as 'sudo'
#
# Example: sudo .rh-diskavail.sh
#
for TARGETBLOCKDEVICE in $(ls /dev | grep "sd[a-z]" | grep -v "sd[a-z][0-9]"); 
do 
	# assign the first partition listed to a block device
  TARGETBLOCKPART=$(ls /dev | grep $TARGETBLOCKDEVICE[0-9] | head -1);  
  if [ -b /dev/$TARGETBLOCKPART ]; 
    then 
			# if partition(s) exists, do nothing
			TARGETBLOCKDEVICESIZE=$(fdisk -l /dev/$TARGETBLOCKDEVICE | head -2 | awk -F ' ' '{print $3}' | sed '/^\s*$/d')
			echo "$TARGETBLOCKDEVICE is partitioned and is $TARGETBLOCKDEVICESIZE GB in size"; 
    else 
			# if partion(s) DON'T exist, see what storage is available
			TARGETBLOCKDEVICESIZE=$(fdisk -l /dev/$TARGETBLOCKDEVICE | head -2 | awk -F ' ' '{print $3}' | sed '/^\s*$/d')
			echo "$TARGETBLOCKDEVICE is NOT partitioned and is $TARGETBLOCKDEVICESIZE GB in size";
  fi; 
done
