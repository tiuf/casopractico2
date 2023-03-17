---
# La función de este rol es instalar todo los paquetes necesarios en la vm1, también un pull de nuestro registry de la imagen creada por nosotros y levanta el contenedor con podman.


#En esta parte hace la instalación de los paquetes necesarios
- name: Install a list of packages with a list variable
  ansible.builtin.yum:
    name: "{{ packages }}"
  vars:
    packages:
    - httpd
    - httpd-tools
    - httpd
    - podman
    - skopeo
    - openssl

#En esta parte se hace el pull de la imagen del registry que hemos creado con terraform.
- name: Pull an image
  containers.podman.podman_image:
    name: casopractico2webserver.azurecr.io/webserver:casopractico2

#En esta parte se levanta un container con podman con la imagen que previamente hemos hecho el pull.
- name: Start a container
  containers.podman.podman_container:
    name: webserver
    image: casopractico2webserver.azurecr.io/webserver:casopractico2
    state: started
    ports:
        - "8080:443"
