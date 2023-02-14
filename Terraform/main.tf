terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

provider "azurerm" {
  features {}
}

resource "azurerm_template_deployment" "example" {
  name                = "ISE-Azure"
  resource_group_name   = "ekorneyc-RG"

  template_body = file("template.json")

  parameters = {
    "hostName" = "ISE-AZURE"
    "SSHKeyPairName" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCss5NKsOpBz06tWVecl2aLumea+4WOwUDqXYwlif7owDcp6r9fsGwEWaDywOHZ/4e9YXZTgiwWcw7E/q8ntSe4RZlkzG4M3teoTmbCjFJrV+tpAwcPAS9FUG+e1Pa5edf8I9w7FVF4cSb0Q9BOvY2uTJy5OOfXIc5MecVpFyosJDbKv/aE3oJNXZYIyYQV+qFx4mC/9qq6FZK5hvmMvYbNZzdbylbpZ8rktEaYhKoiA7erptluGpsv+WrUdt0r4DjoI6tCExancFpUzmTI0wDchn2FJlF54hqhl7/a+EYcPeXERqM0UT3TE214i7cApGdJPcL6B5RNgNiuAVQKOF2P4vKmMNGAxyFggCzQUyPqbAvv6BnKUahYhgU+7jhQ6Zs33fYAlVjLWK45QS7X0f2/AA7ZdsPtb+dJHK80JNSTVAPMMMDpszdIcjqXfztJXKeuMRk2BBKUb3EJKH+msUbxK2tJo5vSlYKGT2NMnzgtQjHX39bPt4+Qu2fGFNZhUxk= generated-by-azure"
    "managementNetwork" = "vnet01"
    "managementNSG" = ""
    "managementSubnet" = "subnet5"
    "managementPrivateIP" = "10.1.4.100"
    "publicIpName" = "ISE-AZURE-ip"
    "publicIpNewOrExisting" = "new"
    "publicIpResourceGroupName" = "ekorneyc-RG"
    "publicIPAllocationMethod" = "Dynamic"
    "publicIpSku" = "Basic"
    "timeZone" = "Etc/UTC"
    "instanceType" = "Standard_F16s_v2"
    "storageType" = "Premium_LRS"
    "DNSDomain" = "example.com"
    "nameServer" = "172.31.0.2"
    "NTPServer" = "time.nist.gov"
    "ERS" = "yes"
    "openAPI" = "yes"
    "PXGrid" = "no"
    "PXGridCloud" = "no"
    "systemPassword" = "Krakow123"
    "location" = "eastus"
  }

  deployment_mode = "Incremental"

}

resource "aws_instance" "ise1" {
  ami = "ami-08c545c5ef3cacced"
  instance_type = "c5.4xlarge"
  user_data = "${file("user_data_ise1")}"
  key_name = "AWS2"
  subnet_id = "subnet-00c74ba0977cdcf9c"
  private_ip = "172.31.200.200"
  security_groups = ["sg-019798ca1592bb4c4"]
  tags = {
    Name = "ISE-AWS"
  }
}

resource "aws_route53_record" "ise1-A-record" {
    zone_id = "Z011471630VVLAEXNVXKN"
    name = "ise-aws.example.com"
    type = "A"
    records = ["172.31.200.200"]
    ttl = "300"
}

resource "aws_route53_record" "ise2-A-record" {
    zone_id = "Z011471630VVLAEXNVXKN"
    name = "ise-azure.example.com"
    type = "A"
    records = ["10.1.4.100"]
    ttl = "300"
}

resource "aws_route53_record" "ise1-PTR-record" {
    zone_id = "Z03304623D84XU6T7168L"
    name = "200.200.31.172.in-addr.arpa"
    type = "PTR"
    records = ["ise-aws.example.com"]
    ttl = "300"
}

resource "aws_route53_record" "ise2-PTR-record" {
    zone_id = "Z0836394G1EFTIVA7EA1"
    name = "100.4.1.10.in-addr.arpa"
    type = "PTR"
    records = ["ise-azure.example.com"]
    ttl = "300"
}

#resource "azurerm_resource_group" "rg" {
#  location = "eastus"
#  name     = "ekorneyc_RG"
#}


# Quick start puts it in variable:

#variable "resource_group_location" {
#  default     = "eastus"
#  description = "Location of the resource group."
#}
#
#variable "resource_group_name_prefix" {
#  default     = "rg"
#  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
#}

# Create virtual network
#resource "azurerm_virtual_network" "my_terraform_network" {
#  name                = "myVnet"
#  address_space       = ["10.0.0.0/16"]
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#}

# Create subnet
#resource "azurerm_subnet" "my_terraform_subnet" {
#  name                 = "mySubnet"
#  resource_group_name  = azurerm_resource_group.rg.name
#  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
#  address_prefixes     = ["10.0.1.0/24"]
#}



# Connect the security group to the network interface
#resource "azurerm_network_interface_security_group_association" "example" {
#  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
#  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
#}

# Generate random text for a unique storage account name
#resource "random_id" "random_id" {
#  keepers = {
#    # Generate a new ID only when a new resource group is defined
#    resource_group = "ekorneyc_RG"
#  }#
#
#  byte_length = 8
#}

# Create storage account for boot diagnostics
#resource "azurerm_storage_account" "my_storage_account" {
#  name                     = "diag${random_id.random_id.hex}"
#  location            = "eastus"
#  resource_group_name = "ekorneyc_RG_tmp"
#  account_tier             = "Standard"
#  account_replication_type = "LRS"
#}

# Create (and display) an SSH key
#resource "tls_private_key" "example_ssh" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# Create Storage Image Reference  

# Create Network Security Group and rule
#resource "azurerm_network_security_group" "my_terraform_nsg" {
#  name                = "myNetworkSecurityGroup"
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#
#  security_rule {
#    name                       = "SSH"
#    priority                   = 1001
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_range     = "22"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#}




# Create public IPs
#resource "azurerm_public_ip" "my_terraform_public_ip" {
#  name                = "ISEPublicIP"
#  location            = "eastus"
#  resource_group_name = "ekorneyc-RG"
#  allocation_method   = "Dynamic"
#}


# Create network interface
#resource "azurerm_network_interface" "my_terraform_nic" {
#  name                = "ISE_NIC"
#  location            = "eastus"
#  resource_group_name = "ekorneyc-RG"

#  ip_configuration {
#    name                          = "my_nic_configuration"
#    subnet_id                     = "/subscriptions/90b31e6d-1943-4a18-8b23-979c6d2995ea/resourceGroups/ekorneyc-RG/providers/Microsoft.Network/virtualNetworks/vnet01/subnets/subnet5"
#    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
#  }
#}


## Create virtual machine
#resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
#  name                  = "ISE-TF"
#  location              = "eastus"
#  resource_group_name   = "ekorneyc-RG"
#  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
#  size                  = "Standard_F16s_v2"
#  custom_data           = filebase64("user_data_ise2")

#  source_image_reference {
#    publisher = "cisco"
#    offer     = "cisco-ise-virtual"
#    sku       = "cisco-ise_3_2"
#    version   = "latest"
#  }
#  plan {
#    name      = "cisco-ise_3_2"
#    publisher = "cisco"
#    product   = "cisco-ise-virtual"
#  }


#  os_disk {
#    name                 = "myOsDisk"
#    caching              = "ReadWrite"
#    storage_account_type = "Premium_LRS"
#    disk_size_gb         = "600"
#  }

#  computer_name                   = "ise-vm"
#  admin_username                  = "iseadmin"
#  disable_password_authentication = true
#
#  admin_ssh_key {
#    username   = "iseadmin"
#    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCss5NKsOpBz06tWVecl2aLumea+4WOwUDqXYwlif7owDcp6r9fsGwEWaDywOHZ/4e9YXZTgiwWcw7E/q8ntSe4RZlkzG4M3teoTmbCjFJrV+tpAwcPAS9FUG+e1Pa5edf8I9w7FVF4cSb0Q9BOvY2uTJy5OOfXIc5MecVpFyosJDbKv/aE3oJNXZYIyYQV+qFx4mC/9qq6FZK5hvmMvYbNZzdbylbpZ8rktEaYhKoiA7erptluGpsv+WrUdt0r4DjoI6tCExancFpUzmTI0wDchn2FJlF54hqhl7/a+EYcPeXERqM0UT3TE214i7cApGdJPcL6B5RNgNiuAVQKOF2P4vKmMNGAxyFggCzQUyPqbAvv6BnKUahYhgU+7jhQ6Zs33fYAlVjLWK45QS7X0f2/AA7ZdsPtb+dJHK80JNSTVAPMMMDpszdIcjqXfztJXKeuMRk2BBKUb3EJKH+msUbxK2tJo5vSlYKGT2NMnzgtQjHX39bPt4+Qu2fGFNZhUxk= generated-by-azure"
#  }#
#
#}
#  boot_diagnostics {
#    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
#  }

