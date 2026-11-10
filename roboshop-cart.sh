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

echo "script path:$script_dir"

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

dnf module disable nodejs -y &>> $log_file
dnf module enable nodejs:24 -y &>> $log_file
dnf install nodejs -y &>> $log_file
Validate $? "Installing NodeJS:24"

node -v | tee -a $log_file
id roboshop &>> $log_file
if [ $? != 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    Validate $? "Creating system user"
else
    echo -e "User already exist....${Y}SKIPPING${N}"
fi

rm -rf /app
Validate $? "Removing old code"

mkdir -p /app
Validate $? "Creating App directory"

curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip &>> $log_file
Validate $? "Downloading user"
cd /app
unzip /tmp/cart.zip &>> $log_file
Validate $? "Unzipping Cart.zip"

npm install &>> $log_file
Validate $? "Installing dependencies"


sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/cart.service"
Validate $? "Cart.service edited"
cp "$script_dir/cart.service" /etc/systemd/system/cart.service

systemctl daemon-reload &>> $log_file
systemctl enable cart &>> $log_file
systemctl start cart &>> $log_file
Validate $? "Enable and start Cart"


systemctl restart cart
Validate $? "Restarting cart"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed Execution==="| tee -a $log_file

