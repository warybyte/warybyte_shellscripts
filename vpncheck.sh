# -------------------------------------------------------------------------------------------
# Note: This VPN status checker is specific to Cisco Anyconnect VPN client as run on Redhat 8
# -------------------------------------------------------------------------------------------
#!/bin/bash
VPNTIMEOUT=6;

# get high-level VPN state (Connected/Disconnected)
VPNSTAT=$(/opt/cisco/anyconnect/bin/vpn status | grep "state:" | tail -1 | grep Connected);

if [ $? -eq 0 ];
then
    VPNCT=$(sudo grep "$(date +%b" "%d)" /var/log/messages | grep "Initiating VPN connection to the secure gateway" | tail -1 | awk -F ' ' '{print $3}');

    # convert to connect time to epoch
    VPNECT=$(date -d "$(date +%F) $VPNCT" +%s);

    # diff between current time and last connection
    DIFFEPOCH=$(($(date +%s) - $VPNECT));

    # calulate runtime of VPN
    RUNHOUR=$(($DIFFEPOCH / 60 / 60));
    RUNMIN=$(($DIFFEPOCH / 60 - (60 * $RUNHOUR)));
    echo "VPN: Running $RUNHOUR:$RUNMIN";
    
    if [ $RUNHOUR -gt $VPNTIMEOUT ]
    then
        echo "!!! TIMEOUT WARNING !!!";
    fi
else
    echo "VPN: Disconnected";
fi
