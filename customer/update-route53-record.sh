#!/bin/bash

sleep 240

HOSTED_ZONE_ID=Z22RDN2BH716NA
HOSTNAME=$(cat /home/ec2-user/fqdn.out)
EC2_PUBLIC_IP=$(/usr/bin/ec2-metadata | grep 'public-ipv4:' | cut -d ' ' -f 2)

/usr/bin/aws route53 change-resource-record-sets --hosted-zone-id=${HOSTED_ZONE_ID} --change-batch="{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"${HOSTNAME}\",\"Type\":\"A\",\"TTL\":60,\"ResourceRecords\":[{\"Value\":\"${EC2_PUBLIC_IP}\"}]}}]}"
