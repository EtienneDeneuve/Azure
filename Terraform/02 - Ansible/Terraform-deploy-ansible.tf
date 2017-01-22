provider "azurerm" {
  subscription_id = "<subscription_id>"
  client_id       = "<client_id>"
  client_secret   = "<secret>"
  tenant_id       = "<tenant_id>"
}

variable "RessourceGroupName" {
  default = "RG-Terraform-Ansible"
}

variable "StoragAccountName" {
  default = "terraansible"
}

resource "azurerm_resource_group" "terraform-ansible" {
  name     = "${var.RessourceGroupName}"
  location = "West US"
}

resource "azurerm_virtual_network" "terraform-vnet" {
  name                = "${azurerm_resource_group.terraform-ansible.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.terraform-ansible.name}"
}

resource "azurerm_subnet" "terraform-subnet" {
  name                      = "${azurerm_resource_group.terraform-ansible.name}-subnet"
  resource_group_name       = "${azurerm_resource_group.terraform-ansible.name}"
  virtual_network_name      = "${azurerm_virtual_network.terraform-vnet.name}"
  address_prefix            = "10.0.2.0/24"
  network_security_group_id = "${azurerm_network_security_group.terraform-nsg.id}"
}

resource "azurerm_public_ip" "terraform-pip" {
  name                         = "${azurerm_resource_group.terraform-ansible.name}PublicIp1"
  resource_group_name          = "${azurerm_resource_group.terraform-ansible.name}"
  public_ip_address_allocation = "static"
  location                     = "West US"
}

resource "azurerm_network_security_group" "terraform-nsg" {
  name                = "${azurerm_resource_group.terraform-ansible.name}SecurityGroup1"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.terraform-ansible.name}"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "terraform-network_interface" {
  name                = "${azurerm_resource_group.terraform-ansible.name}-nic"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.terraform-ansible.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.terraform-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.terraform-pip.id}"
  }
}

resource "azurerm_storage_account" "terraform-storage" {
  name                = "${var.StoragAccountName}"
  resource_group_name = "${azurerm_resource_group.terraform-ansible.name}"
  location            = "westus"
  account_type        = "Standard_LRS"

  tags {
    environment = "staging"
  }
}

resource "azurerm_availability_set" "terraform-availability-set" {
  name                = "${azurerm_resource_group.terraform-ansible.name}AvailabilitySet1"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.terraform-ansible.name}"

  tags {
    environment = "Production"
  }
}

resource "azurerm_storage_container" "terraform-container" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.terraform-ansible.name}"
  storage_account_name  = "${azurerm_storage_account.terraform-storage.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "terraform-vm" {
  name                  = "${azurerm_resource_group.terraform-ansible.name}-vm"
  location              = "West US"
  resource_group_name   = "${azurerm_resource_group.terraform-ansible.name}"
  network_interface_ids = ["${azurerm_network_interface.terraform-network_interface.id}"]
  vm_size               = "Standard_A0"
  availability_set_id   = "${azurerm_availability_set.terraform-availability-set.id}"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.terraform-storage.primary_blob_endpoint}${azurerm_storage_container.terraform-container.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_data_disk {
    name          = "datadisk0"
    vhd_uri       = "${azurerm_storage_account.terraform-storage.primary_blob_endpoint}${azurerm_storage_container.terraform-container.name}/datadisk0.vhd"
    disk_size_gb  = "1023"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "Production"
  }
}

resource "azurerm_virtual_machine_extension" "Ansible-Install" {
  name                 = "Ansible-Azure-Install"
  location             = "West US"
  resource_group_name  = "${azurerm_resource_group.terraform-ansible.name}"
  virtual_machine_name = "${azurerm_virtual_machine.terraform-vm.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
{
    "fileUris": ["https://raw.githubusercontent.com/EtienneDeneuve/Azure/master/Terraform/Ansible/ansible.sh"],
    "commandToExecute": "sh ansible.sh -s <subscription_id> -c <client_id> -k <secret> -t <tenant_id>",
    "timestamp": "19"
}
SETTINGS
}
