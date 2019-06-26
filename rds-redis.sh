#!/bin/bash

#                            			  #
# Creates rds subnet, RDS, redis subnet and redis #
#                            			  #

display_usage() {
        echo "This script accepts two arguments: aws profile and environment" 
        echo -e "\nAdjust the variables in dev|stg|prod.properties before run it" 
	echo -e "\nUsage:\n ./rds-redis.sh AWSPROFILE dev|stg|prod \n" 
        }

# if less than two arguments supplied, display usage 
        if [  $# -le 1 ]
        then
                display_usage
                exit 1
        fi

# check whether user had supplied -h or --help . If yes display usage 
        if [[ ( $# == "--help") ||  $# == "-h" ]]
        then
                display_usage
                exit 0
        fi

#Parsing the ENV variable from command line
ENV_TYPE=$2
PROPERTIES_FILE=./${ENV_TYPE}.properties
source $PROPERTIES_FILE

Subnet1=$(aws --profile $1 --region $AwsRegion ec2 describe-subnets --subnet-ids --filters "Name=tag:Name,Values=*RabbitMQ cluster & DBs network*" --output json|grep subnet|tr -d ,|tr -d \"|awk {'print $2'});
Subnet2=$(aws --profile $1 --region $AwsRegion ec2 describe-subnets --subnet-ids --filters Name=tag:Name,Values=*RDS* --output json|grep subnet|tr -d ,|tr -d \"|awk {'print $2'});

# Obtaining the precreated Security Group of RabbitMQ
SecurityGroup=$(aws --profile $1 --region $AwsRegion ec2 describe-security-groups --filters Name=group-name,Values='*RabbitMQ*' --query 'SecurityGroups[*].{ID:GroupId}' --output text);

# Obtaining the default availability zone
AvailabilityZone=$(aws --profile $1 --region $AwsRegion ec2 describe-subnets --subnet-ids --filters "Name=tag:Name,Values=*RabbitMQ*" --output json|grep AvailabilityZone|tr -d ,|tr -d \"|awk {'print $2'});

# Obtaining the RDS and ElastiCache inentifier from vpc desc
# Maximum length for the redis identifier is 20 chars
Identifier=$(aws --profile $1 --region $AwsRegion ec2 describe-vpcs --vpc-ids --output text |grep TAGS|awk {'print $3'}|cut -d '.' -f 1,2|tr -d .|cut -c 1-20);

# Creating RdsSubnet
aws --profile $1 --region $AwsRegion rds create-db-subnet-group --db-subnet-group-name $SubnetName --db-subnet-group-description $SubnetName --subnet-ids $Subnet1 $Subnet2;

# Creating RDS
aws --profile $1 --region $AwsRegion rds create-db-instance --db-name $RdsDbName --db-instance-identifier $Identifier --allocated-storage $RdsStorage --db-instance-class $RdsInstanceType --engine postgres --master-username $RdsMasterUsername --master-user-password $RdsPassword --vpc-security-group-ids $SecurityGroup --availability-zone $AvailabilityZone --db-subnet-group-name $SubnetName --preferred-maintenance-window sun:07:51-sun:08:21 --db-parameter-group-name default.postgres10 --backup-retention-period $RdsBackupRetention --preferred-backup-window 03:03-03:33 --no-multi-az --engine-version 10.4 --auto-minor-version-upgrade --license-model postgresql-license --option-group-name default:postgres-10 --no-publicly-accessible --storage-type gp2 --no-storage-encrypted --no-copy-tags-to-snapshot --monitoring-interval 0

# Creating ElastiCacheSubnet
#aws --profile $1 --region $AwsRegion elasticache create-cache-subnet-group --cache-subnet-group-name $SubnetName --cache-subnet-group-description $SubnetName --subnet-ids $Subnet1 $Subnet2;

# Creating ElastiCacheCluster
#aws --profile $1 --region $AwsRegion elasticache create-cache-cluster --cache-cluster-id $Identifier --preferred-availability-zone $AvailabilityZone --num-cache-nodes 1 --cache-node-type $CacheNodeType --engine redis --engine-version 4.0.10 --cache-parameter-group-name default.redis4.0 --cache-subnet-group-name $SubnetName --security-group-ids $SecurityGroup --auto-minor-version-upgrade

#Debug
#echo $Subnet1;
#echo $Subnet2;
#echo $SecurityGroup;
#echo $AvailabilityZone;
#echo $Identifier;
