# Azure 

>_Pour utiliser les scripts Ansible ou Terraform, un Service Principal dans Azure est nécessaire._  <br />
>Si vous ne savez pas le faire, voici un article sur le blog de [Stanislas Quastana](https://stanislas.io/2017/01/02/modeliser-deployer-et-gerer-des-ressources-azure-avec-terraform-de-hashicorp/).


## 1. Ansible
Le dossier contiens des playbook [Ansible](https://www.ansible.com/) pour [Azure](https://azure.microsoft.com/fr-fr/) <br/>
  > Si vous n'avez pas de compte sur Azure creer un compte gratuit [ici](https://azure.microsoft.com/fr-fr/free/) <br/>

### 1. ansible_playbook_azure_inventory.yml <br/>
  Ce playbook permet de verifier si le SDK Pyton Azure est bien configuré.
  
  >Il faut telecharger les fichier "azure_rm.py" et "azure_rm.ini" depuis le repo git de [Ansible](https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/) ou utiliser mon script d'instalation [ici](https://raw.githubusercontent.com/EtienneDeneuve/Azure/master/Terraform/02%20-%20Ansible/ansible.sh)
  
Syntaxe :
```bash  
  ansible-playbook -i azure_rm.py ansible_playbook_azure_inventory.yml 
```
###  2. ansible_playbook_azure_create_vm.yml <br/>
  > Dans le playbook vous devez indiquer une machine avec les modules Azure a la ligne "hosts" et qui doit etre presente dans /etc/ansible/hosts

Ce playbook cree une machine virtuelle dans Azure.
Syntaxe :
```bash  
  ansible-playbook ansible_playbook_azure_create_vm.yml --syntax-check
  ansible-playbook ansible_playbook_azure_create_vm.yml --check
  ansible-playbook ansible_playbook_azure_create_vm.yml
```

## 2. Powershell 
>Le dossier Powershell contiens quelques scripts pour Azure en Powershell.

### 1. Get-cAzureSubscription Function :
```Powershell
PS C:\WINDOWS\system32> Get-cAzureSubscription
Azure connected successfully
Select the subscription for the azure backup deployement
Subscription 1 :

         Subscription Name
         XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX
         XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX


Subscription 2 :

         Subscription Name
         XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX
         XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX


What is the Id of the subscription?

1
Here is the Subscription choosed :

         Subscription Name
         XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX
         XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX
```

## 3. Terraform Folder

### 1. IaaS 
> *Le dossier contient des fichiers terraform pour Azure en mode quick & dirty, je vous recommande de ne pas les utiliser tels quels en production sans les rendre secure !* <br/>

#### 1. TF-Ubuntu-16.04-LTS
Deploie une machine Ubuntu 16.04 LTS dans un Ressource Group avec :
- 1 Vnet  
- 1 Subnet
- 1 Public ip
- 1 Network Security Group
- 1 Network Interface
- 1 Storage account
- 1 Availability Set
- 1 Storage Container
- 1 Machine Virtuelle 

Example usage : 
```bash
  terraform plan TF-Ubuntu-16.04-LTS
  terraform apply TF-Ubuntu-16.04-LTS
```

#### 2. Ansible
Le dossier Ansible contient un fichier Terraform pour créer une machine virtuelle dans Azure, installer et configurer Ansible dans celle-ci 
  > Vous devez modifier le fichier TF a deux endroit :
  > - Ligne 2 a 5 : il est necessaire de mettre des " " 
>```terraform
>provider "azurerm" {
>  subscription_id = "<subscription_id>"
>  client_id       = "<client_id>"
>  client_secret   = "<secret>"
>  tenant_id       = "<tenant_id>"
>}
>```
  > - Ligne 163 : il ne faut pas de " " 
>```terraform
>  settings = <<SETTINGS
>{
>    "fileUris": ["https://raw.githubusercontent.com/EtienneDeneuve/Azure/master/Terraform/02%20-%20Ansible/ansible.sh"],
>    "commandToExecute": "sh ansible.sh -s <subscription_id> -c <client_id> -k <secret> -t <tenant_id>",
>    "timestamp": "19"
>}
>SETTINGS
>```

#### 3. Note
+ Le script ansible.sh est utilisable séparément.

Utilisation : 
```bash
  cd /tmp/ 
  wget https://raw.githubusercontent.com/EtienneDeneuve/Azure/master/Terraform/02%20-%20Ansible/ansible.sh
  chmod +x ansible.sh
  ./ansible -s YOUR-SUBSCRIPTION-XXXX-XXXX-XXXX \ 
    -c CLIENT-ID-VIA-SERVICE-PRINCIPAL \ 
    -k SECURITY_KEY \ 
    -t TENANT_ID
```