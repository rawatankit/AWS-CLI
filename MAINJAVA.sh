#!/bin/bash

### VARIABLE ######

projectName=$1;
instanceType=$2;

### PRINT VARIABLE ######
echo $projectName;

######  CREATE SECURITY GROUP COMMAND WITH secGrp VARIABLE ################

secGrp=$(aws ec2 create-security-group --group-name $projectName"-sec" --description "security group for aws-cli" --output text);

echo $secGrp;

############# ALLOWING PORT IN SECURITY GROUP ########################

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 80 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 443 --cidr 0.0.0.0/0 --output text

aws ec2 authorize-security-group-ingress --group-name $projectName"-sec" --protocol tcp --port 10050 --cidr 0.0.0.0/0 --output text

############### CREATING KEYNAME ############################

aws ec2 create-key-pair --key-name $projectName"-key" --query "KeyMaterial" --output text > $projectName"-key.pem"

##################### LAUNCH INSTANCE WITH instanceId VARIABLE ########################

instanceId=$(aws ec2 run-instances --image-id ami-25c00c46 --security-group-ids $secGrp --count 1 --instance-type $instanceType --key-name $projectName"-key" --query "Instances[0].InstanceId" --output text);

echo $instanceId;

###################### ALLOWCATE ELASTIC-IP ################################

elasticIp=$(aws ec2 allocate-address --region ap-southeast-1 --query AllocationId --output text);

#elasticIp=$(aws ec2 allocate-address --region ap-southeast-1 --query PublicIp --output text);

echo $elasticIp;

sleep 60;

#################### ASSOCIATE ELASTIC-IP ADDRESS WITH INSTANCE #########################

aws ec2 associate-address --instance-id $instanceId --allocation-id $elasticIp;

#aws ec2 associate-address --instance-id $instanceId --elasticIp $elasticIp;

#describe=$(aws ec2 describe-instances --instance-ids $instanceId --filters  "Name=instance-type",Values=t2.micro" --output table);

#describe=$(aws ec2 describe-instances --instance-ids $instanceId --query 'Reservations[].Instances[].[PrivateIpAddress,ElasticIp,Tags[?Key==`Name`].Value[]]' --output table);

######################## DESCRIBE PUBLIC-IP ADDRESS WITH describe VARIABLE  #######################

describe=$(aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[*].Instances[*].PublicIpAddress" --output=text);

#describe=$(aws ec2 describe-instances --instance-ids $instanceId --filter "dns-name" --output=text);


#aws ec2 describe-instances --instance-ids $describe --output text 

#aws ec2 describe-instances --output table

echo $describe;

#echo "ubuntu@"$describe;
########### CHANGE PEM FILE PERMISSION ################

chmod -R 400 $projectName"-key.pem"

#################### SSH TO INSTANCE AND RUN PHP PROJECT REQUIREMENT FROM PhpProject.sh ################

ssh -i $projectName"-key.pem" "ubuntu@"$describe 'bash -s' <JavaProject.sh;
