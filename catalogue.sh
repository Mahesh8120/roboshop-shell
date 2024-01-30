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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs 18"

dnf install nodejs -y  &>> $LOGFILE
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
  VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exits $y skipping $N"
fi


mkdir -p /app

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE
VALIDATE $? "downloading catalogue"


cd /app 

unzip -o /tmp/catalogue.zip  &>> $LOGFILE
VALIDATE $? "unziping catalogue.zip"

cd /app

npm install   &>> $LOGFILE
VALIDATE $? "installing packages"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service  &>> $LOGFILE
VALIDATE $? "copying catalogue.service"

systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "reloading"

systemctl enable catalogue  &>> $LOGFILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying catalogue.service"

dnf install mongodb-org-shell -y
VALIDATE $? "installing mongodb-org"

mongo --host $MONGOD_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "loading catalogue data into mongodb"