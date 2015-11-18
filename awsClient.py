import boto.ec2
import time

ec2 = boto.connect_ec2()
image_instance = ec2.run_instances(image_id='ami-01fa416a', key_name='sample_key_east')
print("Waiting for the instance to spin up")
time.sleep(120)
for instance in ec2.get_all_instances():
    if instance.id == image_instance.id:
        break
with open('inventory', 'a') as file:
    file.write('node1 ansible_ssh_host='+str(instance.instances[0].ip_address)+' ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/sample_key_east.pem\n')
with open('inventory_IPs', 'a') as file:
	file.write(str(instance.instances[0].ip_address)+'\n')

print("Provisioned a server on AWS with IP : "+str(instance.instances[0].ip_address))
print("Instance successfully spun up. Added entry for this server in the inventory file")
