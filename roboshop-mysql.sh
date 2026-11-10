#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
#these are colour codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0]; then
    echo "Please run this script with Sudo access"
    exit 1 #to exit the script if the user is normal user.
fi

mkdir -p $log_folder

timestamp(){
    date "+%F %T"
}


Validate(){ #function
    if [ $1 -ne 0]; then
        echo -e "${2}..${R}FAILED${N}" | tee -a $logs_file #tee is used to display logs on scree as well as sloring in log file
        exit 1
    else
        echo -e "${2}...${G}SUCCESS${N}" | tee -a $log_file

}

echo "[INFO]===Script started execution at $(timestamp)===" &>> log_file # this is save the output of the command in log file.

dnf module enable mysql:8.4 -y
dnf install mysql-server -y
Validate $? "Install Redis"

systemctl enable mysqld
systemctl start mysqld
Validate $? "Enable and start mysql"

mysql_secure_installation --set-root-pass RoboShop@1
Validate $? "Install Redis"

