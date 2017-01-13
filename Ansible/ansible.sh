#!/bin/bash 
while getopts s:c:k:t:h: option
do
        case "${option}" in
                s) AZURE_SUBSCRIPTION_ID=${OPTARG};;
                c) AZURE_CLIENT_ID=${OPTARG};;
                k) AZURE_SECRET=${OPTARG};;
                t) AZURE_TENANT=${OPTARG};;
        esac
done

# create folder 
    mkdir -p /opt/azure/playbook 
    mkdir -p /opt/azure/inventory
    mkdir ~/.azure

# variables 
    ANSIBLE_HOST_FILE=/etc/ansible/hosts
    ANSIBLE_CONFIG_FILE=/etc/ansible/ansible.cfg
    ANSIBLE_MODULE_DIR=/opt/azure
    ANSIBLE_USER_DIR=~/.azure/
    
# installation de ansible et modules pip 
    echo "Install of software-properties-common"
    apt-get --yes --force-yes install software-properties-common
    echo "Install of libssl-dev"
    apt-get install libssl-dev --yes --force-yes
    echo "Adding Ansible Repo"
    apt-add-repository ppa:ansible/ansible
    echo "apt-get update"
    apt-get --yes --force-yes update
    echo "Install of ansible"
    apt-get --yes --force-yes install ansible
    # install sshpass
    echo "Install of sshpass"
    apt-get --yes --force-yes install sshpass
    # install Git
    echo "Install of git"
    apt-get --yes --force-yes install git
    # install python
    echo "Install of python-pip"
    apt-get --yes --force-yes install python-pip
    echo "Upgrade via pip of urllib3 "
    pip install urllib3 --upgrade
    echo "Install via pip version 0.4.4 of msrest"
    pip install msrest==0.4.4 
    echo "Install via pip version 0.4.4 of msrestazure"
    pip install msrestazure==0.4.4 
    echo "Install via pip version 2.0.0rc5 azure"
    pip install azure==2.0.0rc5

# configuration de ansible :
    echo "Backup default config of  Ansible"
    mv ${ANSIBLE_CONFIG_FILE} ${ANSIBLE_CONFIG_FILE}.backup
    echo "Disable of host_key_checking"
    printf "[defaults]\nhost_key_checking = False\n\n" >> "${ANSIBLE_CONFIG_FILE}"
    echo "Shorten the ControlPath to avoid errors with long host names , \
            long user names or deeply nested home directories"
        echo '[ssh_connection]\ncontrol_path = ~/.ssh/ansible-%%h-%%r' \
            >> "${ANSIBLE_CONFIG_FILE}"
    echo "Set the use of SCP if SSH"
    echo "\nscp_if_ssh=True" >> "${ANSIBLE_CONFIG_FILE}"
    echo "Adding 127.0.0.1 in Ansible Host File"
    echo "127.0.0.1" > ${ANSIBLE_HOST_FILE}

#chargement des modules azure ansible depuis le git 
    echo "Download the Azure Inventory Script from Ansible Git"
    cd ${ANSIBLE_MODULE_DIR}/inventory
    wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/azure_rm.py
    wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/azure_rm.ini
    chmod +x ${ANSIBLE_MODULE_DIR}/inventory/azure_rm.py

#creation du credentials file
    echo "Create the Credential file for Azure"
printf '[default]
subscription_id=%s
client_id=%s
secret=%s
tenant=%s
' ${AZURE_SUBSCRIPTION_ID} ${AZURE_CLIENT_ID} ${AZURE_SECRET} ${AZURE_TENANT} > ~/.azure/credentials

#creation du playbook de test
    echo "Create the test of the inventory for azure "
echo '- name: Test the inventory script
  hosts: azure
  connection: local
  gather_facts: no
  tasks:
    - debug: msg="{{ inventory_hostname }} has powerstate {{ powerstate }}"
' >  ${ANSIBLE_MODULE_DIR}/playbook/test.yml

echo "Launching the Ansible Inventory..."
ansible-playbook -i ${ANSIBLE_MODULE_DIR}/inventory/azure_rm.py  ${ANSIBLE_MODULE_DIR}/playbook/test.yml 