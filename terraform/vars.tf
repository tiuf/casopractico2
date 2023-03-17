
#Declaramos la variable rg-createdbyTF que es del tipo resource group name
variable "resource_group_name" {
  default = "rg-createdbyTF"
}

#Declaramos la variable location_name donde le ponemos el valor de la región por defecto que utilizaremos, en este caso uksouth
variable "location_name" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  default = "uksouth"
}

#Declaramos la variable public_key_path en la que indicamos la ruta donde guardaremos la clave publico de acceso a las instancias
variable "public_key_path" {
  type = string
  description = "Ruta para la clave pública de acceso a las instancias"
  default = "~/.ssh/id_rsa.pub"
}

#Declaramos la variable ssh_user en la que indicamos que azuereuser es el usuario por defecto que luego utilizaremos para poder hacer ssh a las instancias
variable "ssh_user" {
  type = string
  description = "Usuario para hacer ssh"
  default = "azureuser"
}

#Variable de red
variable "network_name" {
  default = "vnet1"
}

#Variable de subred
variable "subnet_name" {
  default = "subnet1"
}

