# K8s-php

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![PHP](https://img.shields.io/badge/php-%23777BB4.svg?style=for-the-badge&logo=php&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%240db7ed.svg?style=for-the-badge&logo=nginx&logoColor=white)
![Prometheus](https://img.shields.io/badge/prometheus-50a.svg?style=for-the-badge&logo=prometheus&logoColor)


This repository provides a complete Kubernetes (K8s) setup for deploying and monitoring a PHP-based web application. It includes manifests for deploying a PHP application served by NGINX, along with a robust monitoring stack using Prometheus, Grafana, Loki, Promtail, Alertmanager, and a custom NGINX exporter. The setup is designed for production-like environments, emphasizing observability, alerting, and scalability.

The PHP application is a simple example (e.g., a basic web app), but the manifests can be adapted for any PHP project. The monitoring component focuses on NGINX metrics, with predefined alerting rules to detect issues like downtime, high load, errors, and traffic spikes.

> [!NOTE]
> Three methods have been implemented to upgrade and set up k8s, with version v1 being recommended for review and use, which is set up using a bash script to set up the cluster.



## Quick Start
   For installtion K8S and Deploy PHP-APP and Monitoring:
````  
   $ git clone https://github.com/imanabr77/K8s-php/tree/main
   $ cd k8s
   $ cd v1-bash  (recommended )
   $ cd vagrant up
   $ cd manifest
   $ ./deploy.sh
````



## Document
> [!IMPORTANT]
> To read TASK and project documents, go to the documents directory.



## Test
> [!IMPORTANT]
> To test the project, such as checking whether monitoring is up and the Real IP, go to the test directory.



## Dependencies
- Vagrant + VirtualBox 
- Ansible
   
   Installing prerequisites.:
   ````
   $ cd arequirements
   $ ./installation-Ansible.sh
   $ ./installation-Vagrant-VirtualBox.sh
   ````