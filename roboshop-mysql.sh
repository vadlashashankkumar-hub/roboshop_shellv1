#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
#these are colour codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo "Please run this script with Sudo access"
    exit 1 #to exit the script if the user is normal user.
fi

mkdir -p $log_folder

timestamp(){
    date "+%F %T"
}


Validate(){ #function
    if [ $1 -ne 0 ]; then
        echo -e "${2}..${R}FAILED${N}" | tee -a $log_file #tee is used to display logs on scree as well as sloring in log file
        exit 1
    else
        echo -e "${2}...${G}SUCCESS${N}" | tee -a $log_file
    fi
}

echo "$(timestamp) [INFO]===Script started execution at ===" 

dnf module enable mysql:8.4 -y &>> $log_file
dnf install mysql-server -y &>> $log_file
Validate $? "Install mysql"

systemctl enable mysqld &>> $log_file
systemctl start mysqld &>> $log_file
Validate $? "Enable and start mysql"

mysql_secure_installation --set-root-pass RoboShop@1
Validate $? "Setting root password"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed Execution==="| tee -a $log_file