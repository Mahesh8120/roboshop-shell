#!/bin /bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "starting payment"

id roboshop  &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop
  VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exits $y skipping $N"
fi

VALIDATE $? "user add"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "starting payment"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "downloading payment.zip"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping payment.zip"

cd /app 

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing reqirements"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying payment.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading payment"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "starting payment"
