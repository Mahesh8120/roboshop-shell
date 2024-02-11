#!/bin/bang

AMI=ami-0f3c7d07486cad139
SG_ID=sg-04bb94f5d828fa09d
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "shipping" "payments" "cart" "catalogue" "user" "web" "dispatch")
ZONE_ID=Z08780431GOB4T1TR5RPR
DOMAIN_NAME=pjdevops.online
for i in "${INSTANCES[@]}"
do 
   echo "instance is :$i"
   if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
   then
         INSTANCES_TYPE="t3.small"
   else
         INSTANCES_TYPE="t2.micro"
   fi     
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type $INSTANCE_TYPE --security-group-ids sg-087e7afb3a936fce7 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        ' 
done



