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
yum install golang -y

VALIDATE $? "installing golang"

id roboshop &>>LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>LOGFILE
fi

if ! [ -d "/app" ]; then
    mkdir /app &>>LOGFILE
    VALIDATE $? "creating app directory"
fi

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip

VALIDATE $? "downloading artifacts"

cd /app 

VALIDATE $? "moving to app directory"

unzip /tmp/dispatch.zip

VALIDATE $? "unzipping dispatch"

go mod init dispatch

VALIDATE $? "initializing a new go module"

go get 

VALIDATE $? "adding dependencies to go module"

go build

VALIDATE $? "compiling source and generating an executable binary files"

cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service

VALIDATE $? "copying dispatch service"

systemctl daemon-reload

VALIDATE $? "daemon-reload"

systemctl enable dispatch

VALIDATE $? "enabling dispatch"

systemctl start dispatch

VALIDATE $? "starting dispatch"