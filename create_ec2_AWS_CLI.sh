#!/bin/bash

TYPE=t2.micro
SG="0bc7d9b1c87c03fda"
NAMES=("web" "mongodb" "catalogue" "redis" "user" "cart" "mysql" "shipping" "rabbitmq" "payment" "dispatch")
IMAGE_ID=("0fd942b40a76c2599" "04b5b75e9f7910bb9" "031ceaf05c1ef930a" "0997cc251a27f391e" "05b5014646fa8cb35" "031bc99be82029207" "0500348840b52feaf" "04cd7990e85424147" "096b87ab37da42bdc" "0f6097a2169fbe6d2" "0f97655db7a03fdc6")
DOMAIN_NAME="nowheretobefound.online"

# Make sure NAMES and IMAGE_ID arrays have the same length
if [ ${#NAMES[@]} -ne ${#IMAGE_ID[@]} ]; then
    echo "Error: NAMES and IMAGE_ID arrays should have the same length"
    exit 1
fi

for ((i=0; i<${#NAMES[@]}; i++)); do
    name="${NAMES[i]}"
    id="${IMAGE_ID[i]}"

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-$id --instance-type $TYPE --security-group-ids sg-$SG --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$name}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "Instance created for $name with IP address: $IP_ADDRESS"


    aws route53 change-resource-record-sets --hosted-zone-id Z09648415EWTRMGISXVI --change-batch '
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