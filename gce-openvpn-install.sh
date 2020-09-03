#!/bin/bash

# check if gcloud account is available
# https://cloud.google.com/sdk/gcloud/reference/auth/list
# https://stackoverflow.com/questions/35311686/how-to-get-the-active-authenticated-gcloud-account
echo
echo ---

acc_auth=$(gcloud config get-value account)
if [ ! -z '$acc_auth' ]  # not null
then
  echo 'gcloud account is authenticated:' ${acc_auth}
else
  echo 'gcloud auth required'
fi


# set constants
echo
echo ---

read -e -p 'PROJECT_ID: ' -i 'personal-openvpn' PROJECT_ID
read -e -p 'VM_NAME: ' -i 'vm-personal-openvpn' VM_NAME
read -e -p 'MACHINE_TYPE: ' -i 'f1-micro' MACHINE_TYPE
read -e -p 'ZONE: ' -i 'us-central1-c' ZONE

# create google cloud project
echo 'Checking if PROJECT_ID is already available on gcloud.'
echo 'A new project can be created automatically but it will have to be manually assigned a billing account'
echo 'Do that manually and run the script again or go create the project manually, assign a billing account'
echo 'and run the script again providing the PROJECT_ID of the newly created project'

echo
echo ---

project_list=$(gcloud projects list | grep $PROJECT_ID)
if [ -z '$project_list' ]
then
  gcloud projects create $PROJECT_ID
else
  echo 'project is already created'
fi
gcloud config set project $PROJECT_ID

# create VM
echo
echo ---

instance_list=$(gcloud compute instances list | grep $VM_NAME)
if [ -z '$instance_list' ]
then
  gcloud compute instances create $VM_NAME --machine-type=$MACHINE_TYPE --zone=$ZONE --tags=$VM_NAME'-fw-rule-tag'
else
  echo 'VM instance is already created'
fi

# open ports for openvpn
# https://cloud.google.com/sdk/gcloud/reference/compute/firewall-rules/create
echo
echo ---

rules_list=$(gcloud compute firewall-rules list | grep $VM_NAME'-fw-rule')
if [ -z '$instance_list' ]
then
  gcloud compute firewall-rules create $VM_NAME'-fw-rule' --allow tcp:1194,udp:1194 --target-tags=$VM_NAME'-fw-rule-tag'
else
  echo 'Firewall rule is already created'
fi

#login into VM and install openvpn
# https://cloud.google.com/sdk/gcloud/reference/compute/ssh
echo
echo ---

gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID \
  --command='sudo apt-get install wget && wget https://git.io/vpn -O openvpn-install.sh && sudo bash openvpn-install.sh'

# # add more clents?
#
# # get ovpn files
# # https://cloud.google.com/sdk/gcloud/reference/compute/scp
# gcloud compute scp $VM_NAME:~/root/openvpn/ ~/openvpn_ovpn/.
