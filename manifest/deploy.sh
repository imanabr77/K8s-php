#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# SSH into Vagrant master node if not already there
if [[ "$(hostname)" != "k8s-master" ]]; then
  echo -e "${GREEN}Connecting to Vagrant master node...${NC}"
  vagrant ssh k8s-master -- <<-'ENDSSH'
    cd /vagrant  # Assuming your files are synced to /vagrant

    # Disabled taint master for deploy and high performance
    echo -e "\033[0;32mDisabled taint...\033[0m"
    kubectl taint nodes k8s-master node-role.kubernetes.io/control-plane:NoSchedule-
    
    # Create namespace
    echo -e "\033[0;32mCreating namespace...\033[0m"
    kubectl apply -f namespace.yml

    # Deploy monitoring stack
    echo -e "\n\033[0;32mDeploying monitoring components...\033[0m"

    ## Prometheus
    kubectl apply -f monitoring/prometheus/prometheus-configmap.yaml
    kubectl apply -f monitoring/prometheus/prometheus-deployment.yaml
    kubectl apply -f monitoring/prometheus/prometheus-service.yaml

    ## Alertmanager
    kubectl apply -f monitoring/alert-manager/alertmanager-configmap.yaml
    kubectl apply -f monitoring/alert-manager/alertmanager-deployment.yaml
    kubectl apply -f monitoring/alert-manager/alertmanager-service.yaml

    ## Grafana
    kubectl apply -f monitoring/grafana/grafana-deployment.yaml
    kubectl apply -f monitoring/grafana/grafana-service.yaml

    ## Loki Stack
    kubectl apply -f monitoring/loki/loki-configmap.yaml
    kubectl apply -f monitoring/loki/loki-deployment.yaml
    kubectl apply -f monitoring/loki/loki-service.yaml
    kubectl apply -f monitoring/loki/promtail-configmap.yaml
    kubectl apply -f monitoring/loki/promtail-daemonset.yaml

    ## NGINX Exporter
    kubectl apply -f monitoring/nginx-exporter/nginx-exporter-deployment.yaml
    kubectl apply -f monitoring/nginx-exporter/nginx-exporter-service.yaml

    # Deploy PHP application
    echo -e "\n\033[0;32mDeploying PHP application...\033[0m"

    ## Configurations
    kubectl apply -f php-app/nginx-configmap.yaml
    kubectl apply -f php-app/php-configmap.yaml
    kubectl apply -f php-app/app-code-configmap.yaml

    ## Application
    kubectl apply -f php-app/deployment.yml
    kubectl apply -f php-app/service.yaml

    # Verify deployment
    echo -e "\n\033[0;32mVerifying deployment...\033[0m"
    sleep 10  # Wait for pods to initialize

    echo -e "\n\033[0;32mPod status:\033[0m"
    kubectl get pods -n monitoring
    kubectl get pods -n php-app

    echo -e "\n\033[0;32mServices:\033[0m"
    kubectl get svc -n monitoring
    kubectl get svc -n php-app

    echo -e "\n\033[0;32mDeployment complete!\033[0m"
ENDSSH
else
  # Local execution fallback
  echo -e "${GREEN}Already on k8s-master, running deployment locally...${NC}"
  # ... [paste the original deployment script here] ...
fi