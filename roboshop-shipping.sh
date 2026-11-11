#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
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
        echo -e "${2}..${R}FAILED${N}" | tee -a $log_file #tee is used to display logs on scree as well as sloring in log file
        exit 1
    else
        echo -e "${2}...${G}SUCCESS${N}" | tee -a $log_file
    fi
}

echo "$(timestamp) [INFO]===Script started execution at ===" 

dnf module enable maven:3.9 -y
dnf install maven java-25-openjdk-devel -y
Validate $? "Installing Java and maven"

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
Validate $? "setting java 25 as default version"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
Validate $? "setting JAVA_HOME for maven"

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

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $log_file
Validate $? "Downloading shipping application"
cd /app
unzip /tmp/cart.zip &>> $log_file
Validate $? "Unzipping shipping.zip"



mvn clean package &>> $log_file
Validate $? "Installing dependencies"

mv target/shipping.jar shipping.jar
Validate $? "Moving Shipping.Jar file"

dnf install mysql -y
Validate $? "Installing Mysql client"

#mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
#Validate $? "Loading shipping data"

#mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
#Validate $? "Moving Shipping.Jar file"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/shipping.service"
Validate $? "CShippingart.service edited"
cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service

systemctl daemon-reload &>> $log_file
systemctl enable shipping &>> $log_file
systemctl start shipping &>> $log_file
Validate $? "Enable and start shipping"



systemctl restart shipping
Validate $? "Restarting shipping"
echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO]====Script completed Execution==="| tee -a $log_file
