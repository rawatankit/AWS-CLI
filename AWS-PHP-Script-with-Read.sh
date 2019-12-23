#!/bin/bash

####################################################################################################
    #######   THIS SCRIPT IS FOR CREATING PHP PROJECT REQUIREMENT INCLUDING RDS INSTANCE ########
###################################################################################################

################### READ #################

echo  "what is project name?"
read projectName
echo
echo $projectName;

echo  "what is Ec2instanceType?"
read Ec2instanceType
echo
echo $Ec2instanceType;

echo "what is databaseName?"
read databaseName
echo
echo $databaseName;

echo "what is dbinstanceType?"
read dbinstanceType
echo
echo $dbinstanceType;

echo  "dbuserName?"
read dbuserName
echo
echo $dbuserName;

echo "dbPassword?"
read dbPassword
echo
echo $dbPassword;   ################# THIS WON'T WORK WITH SPECIAL CHARACTER SUCH AS !,@ ##########################################

							################# VARIABLES ########################

									# projectName=$1;
									# Ec2instanceType=$2;
									# databaseName=$3;
									# dbinstanceType=$4;
									# dbuserName=$5;
									# dbPassword=$6;   ######## THIS WON'T WORK WITH SPECIAL CHARACTER SUCH AS !,@ ########



##########################  CREATE EC2 INSTANCE SECURITY GROUP COMMAND WITH secGrp VARIABLE ####################

secGrp=$(aws ec2 create-security-group --group-name $projectName"-sec" --description "security group for aws-cli" --output text);

echo $secGrp;


#################### ALLOWING PORT IN EC2 SECURITY GROUP ###################################

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 80 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 443 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 10050 --cidr 0.0.0.0/0 --output text


################## CREATING KEYNAME FILE FOR EC2 INSTANCE  ############################

aws ec2 create-key-pair --key-name $projectName"-key" --query "KeyMaterial" --output text > $projectName"-key.pem"


######################## LAUNCH EC2 INSTANCE WITH instanceId VARIABLE ###########################

################################### WILL LAUNCH EC2 INSTANCE WITH VOLUME GP2 BUT VOLUME SIZE IS DEFAULT 8 GB #########################################


#####    instanceId=$(aws ec2 run-instances --image-id ami-25c00c46 --security-group-ids $secGrp --count 1 --instance-type $Ec2instanceType --key-name $projectName"-key" --query "Instances[0].InstanceId" --output text);

#################################### WILL LAUNCH EC2 INSTANCE WITH VOLUME STANDARD (MAGNETIC) WITH MENTION VOLUME SIZE ##################################


############ instanceId=$(aws ec2 run-instances --image-id ami-09d2fb69 --security-group-ids $secGrp --count 1 --instance-type $Ec2instanceType --key-name $projectName"-key" --query "Instances[0].InstanceId" --output text --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 32 } } ]");

################################## WILL LAUNCH EC2 INSTANCE WITH VOLUME GP2 AND MENTION VOLUME SIZE ##########################################################


instanceId=$(aws ec2 run-instances --image-id ami-09d2fb69 --security-group-ids $secGrp --count 1 --instance-type $Ec2instanceType --key-name $projectName"-key" --query "Instances[0].InstanceId" --output text --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 32 , \"VolumeType\": \"gp2\" } } ]");

echo $instanceId;


#################### GIVE NAME TO EC2 INSTANCE ######################

instancename=$(aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=$projectName --output text);

echo $instancename;


########################## ALLOWCATE ELASTIC-IP ###################################

####  elasticIp=$(aws ec2 allocate-address --region ap-southeast-1 --query AllocationId --output text);

##### elasticIp=$(aws ec2 allocate-address --region ap-southeast-1 --query PublicIp --output text);

elasticIp=$(aws ec2 allocate-address --region us-west-1 --query AllocationId --output text);


echo $elasticIp;

sleep 60;


#################### ASSOCIATE ELASTIC-IP ADDRESS WITH EC2 INSTANCE #########################

aws ec2 associate-address --instance-id $instanceId --allocation-id $elasticIp;

#aws ec2 associate-address --instance-id $instanceId --elasticIp $elasticIp;



######################## DESCRIBE PUBLIC-IP ADDRESS WITH describe VARIABLE  #######################

describe=$(aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[*].Instances[*].PublicIpAddress" --output=text);


echo $describe;

########### CHANGE PEM FILE PERMISSION ################

chmod -R 400 $projectName"-key.pem"




###############################################################################################################
                           #######        RDS INSTANCE LAUNCH SCRIPT  ########
###############################################################################################################


#!/bin/bash


########################## THIS WILL CREATE SECURITY GROUP FOR RDS #############################

securityGroup=$(aws ec2 create-security-group --group-name $projectName"-RDS-cli-securitygroup" --description "security group for RDS-aws-cli" --output text);

echo $securityGroup;

####################### THIS WILL ALLOW PORTS WITH IP ON RDS SECURITY GROUP #######################

aws ec2 authorize-security-group-ingress --group-name $projectName"-RDS-cli-securitygroup" --protocol tcp --port 3306 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-RDS-cli-securitygroup" --protocol tcp --port 3306 --cidr 182.74.105.34/32  --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-RDS-cli-securitygroup" --protocol tcp --port 3306 --cidr 111.93.125.26/32 --output text

############ THIS WILL ATTACH EC2 INSTANCE SECURITY GROUP ID TO RDS SECURITY GROUP ##################

attachinstancegroup=$(aws ec2 authorize-security-group-ingress --group-name $projectName"-RDS-cli-securitygroup" --protocol tcp --port 3306 --source-group $secGrp --output text);


attachinstancegroup=$(aws ec2 authorize-security-group-ingress --group-name $projectName"-RDS-cli-securitygroup" --protocol tcp --port 3306 --source-group $securityGroup --output text);


######## THIS WILL ATTACH RDS INSTANCE SECURITY GROUP ID TO EC2 SECURITY GROUP #######################

attachinstancegroup=$(aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 3306 --source-group $securityGroup --output text);

echo $attachinstancegroup;


############ THIS WILL LAUNCH RDS INSTANCE WITH MULTI AZ,WHEN USE RDS REMOVE AVAILIBILITY ZONE PARAMETER ##############

######## instance=$(aws rds create-db-instance --db-name $databaseName --db-instance-identifier $projectName --allocated-storage 10 --storage-type gp2 --backup-retention-period 7 --multi-az --db-instance-class $dbinstanceType --engine mysql --master-username $dbuserName --master-user-password $dbPassword --vpc-security-group-ids $securityGroup --output text);

############# THIS WILL LAUNCH RDS INSTANCE WITH NO MULTI RDS WITH DEFAULT 1 DAY BACKUP RETENTION PERIOD #################

################# instance=$(aws rds create-db-instance --db-name $databaseName --db-instance-identifier $projectName --allocated-storage 10 --storage-type gp2 --db-instance-class $dbinstanceType --engine mysql --master-username $dbuserName --master-user-password $dbPassword --vpc-security-group-ids  $securityGroup --availability-zone ap-southeast-1b --output text);

############ THIS WILL LAUNCH RDS INSTANCE WITH NO MULTI-RDS WITH BACKUP RETENTION PERIOD 7 DAYS ################


instance=$(aws rds create-db-instance --db-name $databaseName --db-instance-identifier $projectName --allocated-storage 10 --storage-type gp2     --backup-retention-period 7     --db-instance-class $dbinstanceType --engine mysql --master-username $dbuserName --master-user-password $dbPassword --vpc-security-group-ids  $securityGroup --availability-zone us-west-1a --output text);

#echo $instance;


#################### SSH TO INSTANCE AND RUN PHP PROJECT REQUIREMENT FROM PhpProject.sh ################

ssh -i $projectName"-key.pem" "ubuntu@"$describe 'bash -s' <PhpProject.sh;
