# Date: May 27, 2021
# Purpose: Verify if RHEL system has been updated in >45 days
# Dependencies: Remote execution over ssh is advised
#
#!/bin/bash
# Determine date of last 'Erase, Install, Update' from yum history
yumpull=$(sudo yum history 2>&1 | grep "E, I, U" | head -1 | awk -F ' ' '{print $6}');

# Determine 45 day mark from last Yum update
updaterange=$(date -d "$yumpull+45day" +%s);

# Compare Epoch conversion of one date from the other
if [ $(date +%s) -ge $updaterange ];
then
        echo "Warning: Last update outside 45 days.";
else
        echo "Clear: Last update within 45 days.";
fi
