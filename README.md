# Milestone : Deployment

## Tools used
* We have spun up two remote VMs as production servers, one each on AWS and DigitalOcean. For this task, we have reused the scripts developed in HW1
* Using Ansible, we configure the production servers with pre-requisite packages
* Jenkins is being used as the build server

## Tasks

### Configuring a production environment automatically
* A shell script `init.sh` is used to achieve this task.
* `init.sh` does the following tasks:
  * Provision two production servers, one on AWS and the other on DigitalOcean
  * `ssh` into the servers to configure `blue-green` bare git repositories on the production servers
  * Configure the above created bare repos as remote git repos in our app's local repo.

### Deploying software to the production environment triggered after build
* As an M2 task, a `post-commit` hook runs to accept/reject a commit.
* Once the build is successful and the commit is accepted, we push either to the `blue` slice or to the `green` slice.
* This pushes the latest app code to the bare git repos on the production servers and we build the software there.

### Using feature flags to toggle functionality
### Monitoring the deployed application on production servers
### Performing a canary release

## Screencast
* Task 1 : https://youtu.be/X3JRUOGFUkM
* Task 2 : https://youtu.be/SfpmGDn_8B4 
