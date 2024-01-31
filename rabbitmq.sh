#!/bin/bash

ID=(id -u)
TIMESTAMP=$(date+%F-%H-%M-%S)
LOGFILE=/tmp/$0-$TIMESTAMP.log
MONGODB_HOST=mongodb.pjdevops.online

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
  
if [ $ID -ne 0 ]
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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading rabbitmq script"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "user add"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $
VALIDATE $? "setting permissions"