#
# Takes a list of SSH public key signatures and maps them against a number of systems
#
##########################################################################################################################################
# Offline
# assume 'authkeys/' contains a number of authorized_keys files named for the systems they came from, for example:
# authkeys/
# -> server1
# -> server2
# ...
# -> serverN
###########################################################################################################################################
for pertsig in $(cat pertsigs); 
do
  # reset hit count to zero for each key signature
  hits=0;
  echo \
       # echo signature
       $pertsig \
       # echo sum of times this signature is found across each systems authorized_key files
       $(for host in $(ls -1 authkeys/); \
         do \
             hits=$(($hits + $(grep -R $pertsig authkeys/$host | wc -l))); \
         done; \
         echo $hits) \
       # echo the names of hosts that allow this key in space delimited fashion
       $(echo $(grep -R $pertsig authkeys/ | awk -F ':' '{print $1}')); 
done

# Results
# ...
# SHA256:b+vdA....................j8yY 1 server1
# SHA256:f+vdD....................jiug 1 server2
# SHA256:i/XFF....................zlaU 3 server1,server2,server3
# ...
