#!/bin /bash

ID=(id -u)
TIMESTAMP=$(date+%F-%H-%M-%S)
LOGFILE=/tmp/$0-$TIMESTAMP.log

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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>> $LOGFILE
VALIDATE $? "downloading cart"


cd /app 

unzip -o /tmp/cart.zip  &>> $LOGFILE
VALIDATE $? "unziping cart.zip"

cd /app

npm install   &>> $LOGFILE
VALIDATE $? "installing packages"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service  &>> $LOGFILE
VALIDATE $? "copying cart.service"

systemctl daemon-reload  &>> $LOGFILE
VALIDATE $? "reloading"

systemctl enable cart  &>> $LOGFILE
VALIDATE $? "enabling cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "starting cart"

