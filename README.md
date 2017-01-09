#1 Azure 

##1 Ansible deployment script
The script has been tested on Ubuntu 16.04-LTS <br/>
You can use the terraform file to deploy the VM using TF-Ubuntu-16.04-LTS <br/>

Script usage : 
  cd /tmp/ <br/>
  wget https://raw.githubusercontent.com/EtienneDeneuve/Azure/master/ansible.sh <br/>
  chmod +x ansible.sh <br/>
  ./ansible -s YOUR-SUBSCRIPTION-XXXX-XXXX-XXXX \ <br/>
  -c CLIENT-ID-VIA-SERVICE-PRINCIPAL \ <br/>
  -k SECURITY_KEY \ <br/>
  -t TENANT_ID <br/>

##2 Terraform
The Terraform file is a quick and dirty deployment without security ! (yet ;)) <br/>
  terraform plan TF-Ubuntu-16.04-LTS<br/>
  terraform apply TF-Ubuntu-16.04-LTS<br/>
