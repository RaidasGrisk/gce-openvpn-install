#!/bin/bash

# check if google accoutn auth
# https://cloud.google.com/sdk/gcloud/reference/auth/list
# https://stackoverflow.com/questions/35311686/how-to-get-the-active-authenticated-gcloud-account
gcloud auth list --filter=status:ACTIVE --format="value(account)"
gcloud config get-value account

# set constants
PROJECT_ID="personal-openvpn"
VM_NAME="vm-personal-openvpn"
MACHINE_TYPE="f1-micro"
REGION="us-central1-c"

# create google cloud project
gcloud projects create $PROJECT_ID

# create VM
gcloud compute instances create $VM_NAME --machine-type=$MACHINE_TYPE --region=$REGION --tag=$($VM_NAME '_fw_rule_tag')

# open ports for openvpn
# https://cloud.google.com/sdk/gcloud/reference/compute/firewall-rules/create
gcloud compute firewall-rules create $($VM_NAME '_fw_rule') --allow tcp:1194,udp:1194 --target-tags=$($VM_NAME '_fw_rule_tag')

#login into VM and install openvpn
# https://cloud.google.com/sdk/gcloud/reference/compute/ssh
gcloud compute ssh $VM_NAME --zone=$REGION --project=$PROJECT_ID --command="ls"
gcloud compute ssh $VM_NAME --zone=$REGION --project=$PROJECT_ID &&
wget https://git.io/vpn -O openvpn-install.sh &&
sudo bash openvpn-install.sh

# add more clents?

# get ovpn files
# https://cloud.google.com/sdk/gcloud/reference/compute/scp
gcloud compute scp $VM_NAME:~/root/openvpn/ ~/openvpn_ovpn/.
