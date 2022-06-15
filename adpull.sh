#!/bin/bash
######################################################
# Vars defined - $1-$5 are environment vars          #
######################################################
# $1 Active Directory username
# $2 Active Directory user password
# $3 Output file name
# $4 Output file location
# $5 Archive file location
###############
# Unique vars #
###############
ADDOMAIN="test.domain.lcl";
OUDIR="OU=UsersGroups,OU=Development,OU=ApplicationServers,OU=ServerSLA,OU=Company,OU=City,DC=domain,DC=lcl";
OUTFILE="$4/$3.csv";
TIMESTAMP=$(date +%Y%m%d%H%M%S);

#################
# Create Report #
#################
echo "Group,Member" > $OUTFILE;
#
# outer 'for' loop pulls groups, while inner 'for' loop recursively lists users inside respective group.
#
for group in $(ldapsearch -x -H ldap://$ADDOMAIN -w "$2" -D "$1@$ADDOMAIN" -b "$OUDIR" "objectclass=group" dn | grep "dn:" | awk -F '=' '{print $2}' | awk -F ',' '{print $1}');
do
    for user in $(ldapsearch -x -H ldap://$ADDOMAIN -w "$2" -D "$1@$ADDOMAIN" -b "$OUDIR" "(&(objectclass=group)(cn=$group))" member | grep member | awk -F '=' '{print $2}' | awk -F ',' '{print $1}');
    do
        echo "\"$group\",\"$user\"" >> $OUTFILE;
    done;
done;

##################
# Archive report #
##################
cp $OUTFILE $5/$3-$TIMESTAMP.csv;

###################
# Purge old files #
###################
find /upload/archive/ -type f -mtime +90 -exec rm {} \;
