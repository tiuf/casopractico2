---
# tasks file for subirimagen

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


- name: Pull an image
  containers.podman.podman_image:
    name: casopractico2webserver.azurecr.io/webserver:casopractico2

- name: Start a container
  containers.podman.podman_container:
    name: webserver
    image: casopractico2webserver.azurecr.io/webserver:casopractico2
    state: started
    ports:
        - "8080:443"
