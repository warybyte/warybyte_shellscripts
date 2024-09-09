#!/bin/bash
# Description: This script lists and determines if an opensearch index needs replication. Assumption is that desired indices (in this case those that contain *org* and *local*) need at least one replica.
# Last Edit: December 22, 2023 - Work in Progress
#
# Execution: Run this script from /etc/crontab or similar with proper permissions to update the data sets 

INDEXREPORT=/home/opensearch/latest_index.record
INDEXHEALTH=$(curl -X GET "http://localhost:9200/_cluster/health?pretty" | grep status | awk -F ' ' '{print $3}' | sed s/[\",]//g)

# Verify health of cluster. If unhealth, exit script with log note.

if [ $INDEXHEALTH == "green" ]
then
	# create latest index report to parse through (note in my case I was only needing replicate shards with 'org' and 'local' in their name
	
	curl -XGET "http://localhost:9200/_cat/shards/" | grep "org\|local" | grep -v orgs | awk -F ' ' '{print $1}' >> $INDEXREPORT

	# Logic to replicate if 2 or more records aren't found
	
	for REPINDEX in $(cat $INDEXREPORT); 
	do
		# grep -x needed to return exact string.
    		COUNTER=$(grep -x $REPINDEX $INDEXREPORT | wc -l); 
    		if [[ $COUNTER -lt 2 ]]; 
    	then
        	echo "$REPINDEX needs replication";
        	# generate one replica of index document within cluster
        	curl -X PUT "localhost:9200/$REPINDEX/_settings?pretty" -H 'Content-Type: application/json' -d' { "index" : { "number_of_replicas" : 1 } }'
    	else
        	echo "$REPINDEX is replicated";
    	fi;
	done

	# log event and clean up latest report...no real reason to keep it around since it is now stale.
	logger "Index replication job completed"
	rm -f $INDEXREPORT;
else
	logger "Replication of custom indices failed due to cluster health"
fi
