#!/bin /bash

ID=(id -u)
TIMESTAMP=$(date+%F-%H-%M-%S)
LOGFILE=/tmp/$0-$TIMESTAMP.log
MONGODB_HOST=mongodb.pjdevops.online

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
  
if [ $ID -ne 0]
then 
    echo -e "$R error:run this script with root user $N"
    exit 1
else
    echo -e " $G you are root user $N"
fi

VALIDATE(){
 if [ $1 -ne 0 ]
 then
     echo -e "$2......$R Failed $N"
     exit 1
 else
    echo -e "$2.......$G success $N"    
 fi
}

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? " installing remi release"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "enabling redis"

dnf install redis -y  &>> $LOGFILE
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "allowing remote connections"

systemctl enable redis
VALIDATE $? "enabling redis"

systemctl start redis
VALIDATE $? "starting redis"