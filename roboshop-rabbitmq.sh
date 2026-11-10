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

echo "[INFO]===Script started execution at $(timestamp)===" &>> $log_file # this is save the output of the command in log file.

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $log_file
Validate $? "Adding Rabbitmq repo"

dnf install erlang rabbitmq-server -y &>> $log_file

systemctl enable rabbitmq-server &>> $log_file
systemctl start rabbitmq-server &>> $log_file
Validate $? "Enable and start RabbitMQ"

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? != 0 ]; then

    rabbitmqctl add_user roboshop roboshop123 &>> $log_file
    Validate $? "Creating RabbitMQ user for Roboshop"
else
    echo "User is already exist....${Y}SKIPPING${N}"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
Validate $? "Setting permissions for RabbitMQ user for Roboshop"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed Execution==="| tee -a $log_file