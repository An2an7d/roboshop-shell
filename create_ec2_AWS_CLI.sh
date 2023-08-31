#!/bin/bash

TYPE="t2.micro"
SG="0bc7d9b1c87c03fda"
NAMES=$@
DOMAIN_NAME="nowheretobefound.online"
image_id="03265a0778a880afb"
zone_id="Z09648415EWTRMGISXVI"

for name in ${NAMES[@]}; do

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-$image_id --instance-type $TYPE --security-group-ids sg-$SG --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$name}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "Instance created for $name with IP address: $IP_ADDRESS"
    aws route53 change-resource-record-sets --hosted-zone-id $zone_id --change-batch '
    {
                "Comment": "CREATE/DELETE/UPSERT a record ",
                "Changes": [{
                "Action": "CREATE",
                            "ResourceRecordSet": {
                                        "Name": "'$name.$DOMAIN_NAME'",
                                        "Type": "A",
                                        "TTL": 300,
                                    "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
    }}]
    }
    '
done