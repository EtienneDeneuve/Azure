#1 Azure 

##1 Ansible Folder
The script has been tested on Ubuntu 16.04-LTS <br/>
You can use the terraform* file to deploy the VM using TF-Ubuntu-16.04-LTS <br/>


Script usage : 
`  cd /tmp/ 
  wget https://raw.githubusercontent.com/EtienneDeneuve/Azure/master/ansible.sh
  chmod +x ansible.sh
  ./ansible -s YOUR-SUBSCRIPTION-XXXX-XXXX-XXXX \ 
    -c CLIENT-ID-VIA-SERVICE-PRINCIPAL \ 
    -k SECURITY_KEY \ 
    -t TENANT_ID 

`
*Terraform
The Terraform file is a quick and dirty deployment without security ! (yet ;)) <br/>
  terraform plan TF-Ubuntu-16.04-LTS<br/>
  terraform apply TF-Ubuntu-16.04-LTS<br/>

##2 Backup Folder
In this folder you will get some sample for Azure Automation using Powershell