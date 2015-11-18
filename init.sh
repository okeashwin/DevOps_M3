#!/bin/bash

# This script sets up two production servers, one for a blue slice and another for a green slice
#

# remove any previous files
rm -f inventory
rm -f inventory_IPs

sudo apt-get install -y python-pip
pip install -U boto

npm install

echo "[Servers]" > inventory
echo "--------------Provisioning a blue server on Digital Ocean ---------------------------"
# node 0
node digitalOceanClient.js

echo "--------------Provisioning a green server on AWS -------------------------------------"
# node 1
# python awsClient.py

# Set this flag to false for an uninterrupted ssh
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook playbook.yml -i inventory

# ssh into servers and setup the structure
productionServerBlue=`cat inventory_IPs | head -1 | cut -d ' ' -f1`
productionServerGreen=`cat inventory_IPs | tail -1 | cut -d ' ' -f1`

rawBlue=`ssh -t root@$productionServerBlue "pwd" | head -1`
rawGreen=`ssh -t ubuntu@$productionServerGreen -i ~/sample_key_east.pem "pwd" | head -1`

workingDirBlue=`echo $rawBlue | tr -d '\r'`
workingDirGreen=`echo $rawGreen | tr -d '\r'`

echo -e "cd $workingDirBlue\nmkdir deploy\ncd deploy\nmkdir blue.git\nmkdir blue\ncd blue.git\ngit init --bare\ncd $workingDirBlue\necho 'GIT_WORK_TREE=$workingDirBlue/deploy/blue/ git checkout -f' > $workingDirBlue/deploy/blue.git/hooks/post-receive\nchmod +x $workingDirBlue/deploy/blue.git/hooks/post-receive" > blueSetup

scp blueSetup root@$productionServerBlue:~/blueSetup
ssh -t root@$productionServerBlue "chmod +x ~/blueSetup"

# Execute the script
ssh -t root@$productionServerBlue "~/blueSetup"

echo -e "cd $workingDirGreen\nmkdir deploy\ncd deploy\nmkdir green.git\nmkdir green\ncd green.git\ngit init --bare\ncd $workingDirGreen\necho 'GIT_WORK_TREE=$workingDirGreen/deploy/green/ git checkout -f' > $workingDirGreen/deploy/green.git/hooks/post-receive\nchmod +x $workingDirGreen/deploy/green.git/hooks/post-receive" > greenSetup

scp -i ~/sample_key_east.pem greenSetup ubuntu@$productionServerGreen:~/greenSetup
ssh -t ubuntu@$productionServerGreen -i ~/sample_key_east.pem "chmod +x ~/greenSetup"

#Execute the script
ssh -t ubuntu@$productionServerGreen -i ~/sample_key_east.pem "~/greenSetup"
