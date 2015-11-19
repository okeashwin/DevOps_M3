
#!/bin/bash

rm inventory

GIT_REPO="https://github.com/okeashwin/DevOps_M3.git"
GIT_DIR="DevOps_M3"

echo "[Servers]" > inventory
echo "--------------Provisioning a proxy server on Digital Ocean ---------------------------"
# node 0
node ../digitalOceanClient.js node0
sleep 45

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook proxy.yml -i inventory

proxyIP=`cat inventory_IPs | head -1 | cut -d ' ' -f1`

# ssh into the proxy

ssh -t root@$proxyIP "git clone $GIT_REPO"

# prepare a file with commands to setup the proxy
echo -e "cd $GIT_DIR\nsudo service redis-server start\ncd redis_app\nnpm install\nnodejs main.js &\ncd ..\ncd proxy\nnpm install\nnodejs main.js &" > proxySteps

scp proxySteps root@$proxyIP:~/proxySteps
ssh -t root@$proxyIP "chmod +x ~/proxySteps"

# Execute the script
ssh -t root@$proxyIP "~/proxySteps"

