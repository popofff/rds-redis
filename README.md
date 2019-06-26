#                            			 		  #
# Creates rds subnet, RDS, redis subnet and redis #
#                            			          #

AWS CLI on Linux box is required to run the script

The AWS Command Line Interface (CLI) is a unified tool to manage AWS services from the command line and automate some tasks through scripts.
With just one tool to download and configure, you can control multiple AWS services from the command line and automate them through scripts.
This tool will be useful for us since we are going to use S3 storage for backing up purposes, put custom metric into ClaudWatch and also some of our scripts depends on it.

```
    cd /root/
    wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    unzip awscli-bundle.zip
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    complete -C '/usr/bin/aws_completer' aws
    ln -s /usr/local/aws/bin/aws_completer /usr/bin/

```