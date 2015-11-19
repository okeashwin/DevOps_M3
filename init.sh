#!/bin/bash

# This script sets up two production servers, one for a blue slice and another for a green slice
#

# remove any previously existing files
rm -f inventory
rm -f inventory_IPs

sudo apt-get install -y python-pip
pip install -U boto

npm install

PROJECT_HOME=~/JenkinsOnEC2MavenProject

echo "[Servers]" > inventory
echo "--------------Provisioning a blue server on Digital Ocean ---------------------------"
# node 0
node digitalOceanClient.js node0

echo "--------------Provisioning a green server on Digital Ocean --------------------------"
# node 1
node digitalOceanClient.js node1
sleep 45

# Set this flag to false for an uninterrupted ssh
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook playbook.yml -i inventory

# ssh into servers and setup the structure
productionServerBlue=`cat inventory_IPs | head -1 | cut -d ' ' -f1`
productionServerGreen=`cat inventory_IPs | tail -1 | cut -d ' ' -f1`

rawBlue=`ssh -t root@$productionServerBlue "pwd" | head -1`
rawGreen=`ssh -t root@$productionServerGreen "pwd" | head -1`

workingDirBlue=`echo $rawBlue | tr -d '\r'`
workingDirGreen=`echo $rawGreen | tr -d '\r'`

echo -e "cd $workingDirBlue\nmkdir deploy\ncd deploy\nmkdir blue.git\nmkdir blue\ncd blue.git\ngit init --bare\ncd $workingDirBlue\necho 'GIT_WORK_TREE=$workingDirBlue/deploy/blue/ git checkout -f' > $workingDirBlue/deploy/blue.git/hooks/post-receive\nchmod +x $workingDirBlue/deploy/blue.git/hooks/post-receive" > blueSetup

scp blueSetup root@$productionServerBlue:~/blueSetup
ssh -t root@$productionServerBlue "chmod +x ~/blueSetup"

# Execute the script
ssh -t root@$productionServerBlue "~/blueSetup"

echo -e "cd $workingDirGreen\nmkdir deploy\ncd deploy\nmkdir green.git\nmkdir green\ncd green.git\ngit init --bare\ncd $workingDirGreen\necho 'GIT_WORK_TREE=$workingDirGreen/deploy/green/ git checkout -f' > $workingDirGreen/deploy/green.git/hooks/post-receive\nchmod +x $workingDirGreen/deploy/green.git/hooks/post-receive" > greenSetup

scp greenSetup root@$productionServerGreen:~/greenSetup
ssh -t root@$productionServerGreen "chmod +x ~/greenSetup"

#Execute the script
ssh -t root@$productionServerGreen "~/greenSetup"

# Add these bare repos as remote git repos in the project source
cd $PROJECT_HOME
git remote add blue root@$productionServerBlue:$workingDirBlue/deploy/blue.git
git remote add green root@$productionServerGreen:$workingDirGreen/deploy/green.git