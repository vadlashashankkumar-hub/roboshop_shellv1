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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> log_file
Validate $? "Adding mongo repo"

dnf install mongodb-org -y &>> log_file
Validate $? "Install mongodb"

systemctl enable mongod &>> log_file
systemctl start mongod &>> log_file
Validate $? "Enable and start mongod"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> log_file
Validate $? "updating mongoDb configuration"

systemctl restart mongod &>> log_file
Validate $? "Restarting MongoD"

systemctl status mongod | tee -a $log_file

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed Execution==="| tee -a $log_file