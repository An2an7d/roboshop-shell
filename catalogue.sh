#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOGFILE

VALIDATE $? "setting up npm source"

yum install nodejs -y &>>LOGFILE

VALIDATE $? "installing nodejs"

id roboshop &>>LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>LOGFILE
else
    echo "User already exists"
fi

if ! [ -d "/app" ]; then
    mkdir /app &>>LOGFILE
else
    echo "/app directory already exists"
fi

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>LOGFILE

VALIDATE $? "downloading catalogue artifact"

cd /app &>>LOGFILE

VALIDATE $? "moving into app directory"

unzip /tmp/catalogue.zip &>>LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>>LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>LOGFILE

VALIDATE $? "copying catalogue service"

systemctl daemon-reload &>>LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable catalogue &>>LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>LOGFILE

VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>LOGFILE

VALIDATE $? "copying mongo repo"

yum install mongodb-org-shell -y &>>LOGFILE

VALIDATE $? "installing mongo client"

mongo --host mongodb.nowheretobefound.online </app/schema/catalogue.js &>>LOGFILE

VALIDATE $? "loading catalogue data into mongodb"