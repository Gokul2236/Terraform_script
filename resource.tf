provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-webapp"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-webapp"
  address_space        = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Virtual Machines
resource "azurerm_subnet" "example" {
  name                 = "subnet-webapp"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP Address for the Linux VM
resource "azurerm_public_ip" "example" {
  name                = "public-ip-webapp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

# Network Interface for the Linux Virtual Machine
resource "azurerm_network_interface" "example" {
  name                = "nic-webapp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Linux Virtual Machine (Web App Host)
resource "azurerm_linux_virtual_machine" "example" {
  name                = "webapp-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "AdminPassword123"  # Ideally use a secure method to store the password (like Key Vault or environment variables)
  network_interface_ids = [azurerm_network_interface.example.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_id = "/subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.Compute/images/{image_name}"
}

# Azure SQL Server
resource "azurerm_sql_server" "example" {
  name                         = "sqlserver-webapp"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "SqlAdminPassword123"
}

# Azure SQL Database
resource "azurerm_sql_database" "example" {
  name                = "sqldb-webapp"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  server_name         = azurerm_sql_server.example.name
  sku_name            = "B_Gen5_1"
}

# Azure Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "storagewebapp"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

# Azure Storage Blob Container
resource "azurerm_storage_container" "example" {
  name                  = "webapp-container"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# Output Information
output "vm_public_ip" {
  value = azurerm_public_ip.example.ip_address
}

output "sql_db_connection_string" {
  value = "Server=${azurerm_sql_server.example.fully_qualified_domain_name};Database=${azurerm_sql_database.example.name};User Id=${azurerm_sql_server.example.administrator_login};Password=${azurerm_sql_server.example.administrator_login_password};"
}

output "storage_account_name" {
  value = azurerm_storage_account.example.name
}
