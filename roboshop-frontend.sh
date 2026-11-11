#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
script_dir=$(dirname "$(realpath "$0")")
#these are colour codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
domain_name="devopspractice.store"


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
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $log_file #tee is used to display logs on scree as well as sloring in log file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}...${G}SUCCESS${N}" | tee -a $log_file
    fi
}

echo "$(timestamp) [INFO]===Script started execution at ===" 

echo "script path:$script_dir"

dnf module disable nginx -y &>> $log_file
dnf module enable nginx:1.26 -y &>> $log_file
dnf install nginx -y &>> $log_file
Validate $? "Installing Nginx"

systemctl enable nginx &>> $log_file
systemctl start nginx &>> $log_file
Validate $? "Enable and start Nginx"


rm -rf /usr/share/nginx/html/*
Validate $? "Removing default content"



curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $log_file
Validate $? "Downloading payment application"
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $log_file
Validate $? "Unzipping payment.zip"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/roboshop.conf" &>> $log_file
Validate $? "Configuring Reverse Proxy"
cp "$script_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf &>> $log_file

nginx -t
systemctl restart nginx
Validate $? "Restarting Nginx"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed Execution==="| tee -a $log_file
