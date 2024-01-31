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

dnf module disable mysql -y &>> LOGFILE
VALIDATE $? " disablinmg mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> LOGFILE
VALIDATE $? " coping mysql.repo"

dnf install mysql-community-server -y &>> LOGFILE
VALIDATE $? "installing mysql"

systemctl enable mysqld &>> LOGFILE
VALIDATE $? "enabling mysql"

systemctl start mysqld &>> LOGFILE
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting root password mysql"


