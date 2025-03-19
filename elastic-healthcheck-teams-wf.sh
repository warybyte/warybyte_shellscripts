#!/bin/bash

# Description: Elasticsearch status health check for MS TEAMS workflow, run from a Linux machine with access to the Health API of Elastic.
#


# Variables:
#

# MS TEAMS ALERTS CHANNEL
TEAMSCHANNEL="https://prod-xxxx..."


# since MS Workflows requires very specifically formatted JSON payloads, I'm building the template into the script and modifying it on the fly to the output
# from the Elastic healthcheck API. Another way to do this is to have a JSON template file laying around...but who wants to mess with THAT...

PAYLOAD_PRIMER=$(
cat <<EOF
{
    "type": "message",
    "attachments": [
        {
            "contentType": "application/vnd.microsoft.card.adaptive",
            "contentUrl": null,
            "content": {
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.2",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "DATE_PLACEHOLDER",
                        "wrap": "True"
                    },
                    {
                        "type": "TextBlock",
                        "text": "Elastic Healthcheck - STATECHECK",
                        "wrap": "True"
                    }
                ]
            }
        }
    ]
}
EOF
)

# Pull the Elastic state (I'm using jq and sed here to parse out the status field only)
#

ELASTIC_STATE=$(curl -K /opt/so/conf/elasticsearch/curl.config -ks https://localhost:9200/_cluster/health?pretty | jq .status | sed s/'"'//g)

# Logic to simply log state if green, otherwise trigger an alert to Teams channel
#

if [[ $ELASTIC_STATE == "green" ]]
then
        logger "Elastic is $ELASTIC_STATE"
else
        # other possible states are 'yellow' or 'red', assuming the API is running at all. I want to be notified on anything but green.
        #
        
        logger "Elastic has as problem!"
        RUNDATE=$(date +%D" "%R%Z);
        PAYLOAD=$(echo $PAYLOAD_PRIMER | jq '.' | sed "s|DATE_PLACEHOLDER|$RUNDATE|g" | sed "s|STATECHECK|$ELASTIC_STATE|g");
        echo $PAYLOAD
        curl -X POST $TEAMSCHANNEL -H "Content-Type: application/json" -d "$PAYLOAD"
fi
