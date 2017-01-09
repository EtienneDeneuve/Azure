#1 Azure

#2 Ansible deployment script
The script has been tested on Ubuntu 16.04-LTS 
You can use the terraform file to deploy the VM using TF-Ubuntu-16.04-LTS 

Script usage : 
  cd /tmp/
  wget https://raw.githubusercontent.com/EtienneDeneuve/Azure/master/ansible.sh
  chmod +x ansible.sh 
  ./ansible -s YOUR-SUBSCRIPTION-XXXX-XXXX-XXXX \
  -c CLIENT-ID-VIA-SERVICE-PRINCIPAL \
  -k SECURITY_KEY \
  -t TENANT_ID

#3 Terraform
The Terraform file is a quick and dirty deployment without security ! (yet ;))
  terraform plan TF-Ubuntu-16.04-LTS
  terraform apply TF-Ubuntu-16.04-LTS
