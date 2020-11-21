#!/bin/bash

set -xe
source config.sh
packer build -var "security_group=$build_sg" -var "source_ami=$source_ami" -var "region=$region" ami.pkr.hcl

AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ":" -f2)
MY_IP=$(curl -s ifconfig.me/ip)
(
cd terraform
terraform init
terraform apply -var="building_ip=$MY_IP/32" -var="ami_id=$AMI_ID" -var="key_pair=$key_pair" --auto-approve
)
