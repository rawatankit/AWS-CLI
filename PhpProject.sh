#!/bin/bash

#Instructions to use this script 
#
#chmod +x SCRIPTNAME.sh
#
#sudo ./SCRIPTNAME.sh

echo "###################################################################################"
echo "Please be Patient: Installation will start now.......and it will take some time :)"
echo "###################################################################################"

#Update the repositories

sudo -i

sudo apt-get update

#Apache, Php, MySQL and required packages installation

###########     sudo apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt php5-curl git zip


sudo apt-get -y install apache2 php7.0 libapache2-mod-php7.0 php7.0-mcrypt php7.0-curl git zip

service apache2 restart

sudo apt-get -y install mysql-client-5.7

sudo wget http://repo.zabbix.com/zabbix/2.4/ubuntu/pool/main/z/zabbix/zabbix-agent_2.4.7-1+trusty_amd64.deb

sudo dpkg -i zabbix-agent_2.4.7-1+trusty_amd64.deb

sudo apt-get update

sudo apt-get install zabbix-agent

sudo sed -i 's/Server=127.0.0.1/Server=54.66.150.41/' /etc/zabbix/zabbix_agentd.conf

sudo sed -i 's/Hostname=Zabbix server/Hostname=Javaproject1/' /etc/zabbix/zabbix_agentd.conf

service zabbix-agent restart

#### quietly add a user without password #######

sudo adduser --quiet --disabled-password -shell /bin/bash --home /home/newuser --gecos "User" newuser

#### set password #######

sudo echo "newuser:newpassword!123!" |sudo chpasswd

################# GO TO THE DIRECTORY ####################

cd /var/www/html/
sudo mkdir newuser
sudo chown -R newuser:newuser newuser
sudo chmod -R 755 newuser
sudo chsh -s /bin/bash newuser
sudo usermod  -d /var/www/html/newuser newuser

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config


#### RESTART SERVICES ########

#service apache2 restart

sudo service ssh restart

