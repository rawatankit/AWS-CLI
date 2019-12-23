#!/bin/bash

#### Instructions to use this script #### 
#
#chmod +x SCRIPTNAME.sh
#
#sudo ./SCRIPTNAME.sh

echo "###################################################################################"
echo "Please be Patient: Installation will start now.......and it will take some time :)"
echo "###################################################################################"

### Update the repositories ####

sudo apt-get update

####   NGINX  and required packages installation #####

sudo apt-get install -y nginx


#### This command is used to tell shell, turn installation mode to non interactive and set auto selection of agreement for Sun Java ####

export DEBIAN_FRONTEND=noninteractive

echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections

echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections


echo "Bash Script for Installing Sun Java for Ubuntu!"

echo "Now Script will try to purge OpenJdk if installed..."

#### purge openjdk if installed to remove conflict #####

sudo apt-get purge openjdk-\* -y

echo "Now we will update repository..."

sudo apt-get update -y

echo "Adding Java Repository...."

sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:webupd8team/java -y

echo "Updating Repository to load java repository"

sudo apt-get update -y

echo "Installing Sun Java....."
sudo -E apt-get purge oracle-java8-installer -y
sudo -E apt-get install oracle-java8-installer -y

echo "Installation completed...."

echo "Installed java version is...."

java -version


#### quietly add a user without password #####

sudo adduser --quiet --disabled-password -shell /bin/bash --home /home/newuser --gecos "User" newuser

#### set password ####

sudo echo "newuser:newpassword" |sudo chpasswd


########## GO TO DIRECTORY ###############

sudo wget http://mirror.fibergrid.in/apache/tomcat/tomcat-8/v8.0.36/bin/apache-tomcat-8.0.36.tar.gz -P /opt/

cd /opt/

sudo tar -xvzf apache-tomcat-8.0.36.tar.gz

sudo chmod -R 755 apache-tomcat-8.0.36

sudo chown -R newuser:newuser apache-tomcat-8.0.36

cd /opt/apache-tomcat-8.0.36/bin/

sudo ./startup.sh

sudo chsh -s /bin/bash newuser

sudo usermod  -d /opt/apache-tomcat-8.0.36 newuser

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config



### Restart all the installed services to verify that everything is installed properly ####

#echo -e "\n"

service nginx restart > /dev/null

sudo service ssh restart

#echo -e "\n"

#if [ $? -ne 0 ]; then
#   echo "Please Check the Install Services, There is some $(tput bold)$(tput setaf 1)Problem$(tput sgr0)
#else
#   echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
#fi
#
#echo -e "\n"
