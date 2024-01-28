#!/bin/bang

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=($date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log" 

VALIDATE(){
if [ $1 -ne 0 ]
then    
    echo "$2 ....$R FAILED $N"   
else
    echo "$2.....$G SUCCESS $G"
fi         
}         


if [ $ID -ne 0 ]
then 
    echo "error:run this script with root user access"
    exit 1
else
    echo "you are root user"
fi
  
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $?  "copied mongo.repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "installing mongodb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabling mongodb"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mongodb"
 
sed -i 's /127.0.0.0/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "remote access to mongodb"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "restarting mongodb"


