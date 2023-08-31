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

yum install python36 gcc python3-devel -y &>>LOGFILE

VALIDATE $? "installing python" &>>LOGFILE

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

cd /app &>>LOGFILE

VALIDATE $? "moving to app directory" &>>LOGFILE

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>LOGFILE

VALIDATE $? "downloading artifact" 

unzip /tmp/payment.zip &>>LOGFILE

VALIDATE $? "unzipping payment artifact"

pip3.6 install -r requirements.txt &>>LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>LOGFILE

VALIDATE $? "copying payment service"

systemctl daemon-reload &>>LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable payment &>>LOGFILE 

VALIDATE $? "enabling payment"

systemctl start payment &>>LOGFILE

VALIDATE $? "starting payment"