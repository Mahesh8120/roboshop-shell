#!/bin/bash

ID=(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0-$TIMESTAMP.log
MONGODB_HOST=mongodb.pjdevops.online

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
  
if [ $id -ne 0 ]
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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
  VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exits $y skipping $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directopry"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading shipping"

cd /app &>> $LOGFILE
VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping"

cd /app
VALIDATE $? "moving to app directory"

mvn clean package &>> $LOGFILE
VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "rename jar file"

cp /home/centos/roboshop-shell/shipping.service etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "coping shipping.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enable shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "start shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql"

mysql -h mysql.pjdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "setting root password"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping"
