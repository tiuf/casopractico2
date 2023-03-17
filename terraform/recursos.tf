resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name

}

#Creamos el container registry con el nombre casopractico2webserver sin el tag de geolocations dado que es una función del plan premium
resource "azurerm_container_registry" "acr" {
  name                = "casopractico2webserver"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
        }
#Creamos el container registry con el nombre casopractico2appaks sin el tag de geolocations dado que es una función del plan premium
resource "azurerm_container_registry" "acr1" {
  name                = "casopractico2appaks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
        }

#Despliegue de la red virtual de azure
resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#Despliegue de la subred
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Despliegue de la interfaz de red vnic
resource "azurerm_network_interface" "nic" {
  name                = "vnic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
#En esta parte creamos la dirección IP Publica.
resource "azurerm_public_ip" "pip" {
  name                = "vip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}
#Desplegamos la maquina virtual VM1 que utilizaremos para la parte del Webserver

#Levantamos maquina virtual
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
#Indicamos que usuario podra acceder por ssh y la ubicacion de la clave publica
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
#Tipo de disco 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
#Plan de la maquina virtual y producto
  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }

#Origen de la imagen a utilizar
  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}
#Creamos un grupo de seguridad para la red para el puerto 22
resource "azurerm_network_security_group" "nsg1" {
  name                = "securitygroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "sshprule"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 }
#Creamos un grupo de seguridad de la subred enlazado al grupo de seguridad anterior.
resource "azurerm_subnet_network_security_group_association" "nsg-link" {
   subnet_id                 = azurerm_subnet.subnet.id
   network_security_group_id = azurerm_network_security_group.nsg1.id
}
#Creamos una regla de red para el puerto 8080
resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
 }

#En esta parte del codigo desplegamos el cluster de kubernetes con aks con un nodo.
resource "azurerm_kubernetes_cluster" "casopractico2_aks" {
  name                = "aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks1"
#Definimos cuandos nodos y el tipo de vm_size a utilizar
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
#Identidad
  identity {
    type = "SystemAssigned"
  }
#Tag a utilizar
  tags = {
    Environment = "Production"
  }
}
