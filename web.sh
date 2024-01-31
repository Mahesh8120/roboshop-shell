#!/bin /bash

ID=(id -u)
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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"
 
systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enable nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removeing default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "downloading web application"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving html directory"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copied roboshop reverse proxy conf"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarting nginx"