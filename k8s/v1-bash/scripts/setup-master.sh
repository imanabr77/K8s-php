#!/bin/bash

# Set user and shared directory (modify if not using Vagrant)
USER=${USER:-vagrant}
SHARED_DIR=${SHARED_DIR:-/vagrant}
KUBECONFIG_PATH="/home/$USER/.kube/config"

# Initialize the cluster and log output
echo "Initializing Kubernetes cluster..."
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.56.10 | tee /var/log/kubeadm-init.log
if [ $? -ne 0 ]; then
  echo "Error: kubeadm init failed. Check /var/log/kubeadm-init.log for details."
  exit 1
fi

# Set up kubeconfig for the user
echo "Setting up kubeconfig for $USER..."
mkdir -p /home/$USER/.kube
cp -i /etc/kubernetes/admin.conf "$KUBECONFIG_PATH"
chown $USER:$USER "$KUBECONFIG_PATH"

# Set KUBECONFIG environment variable
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /home/$USER/.bashrc
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc
source /home/$USER/.bashrc

# Copy kubeconfig to shared directory for workers
mkdir -p "$SHARED_DIR"
cp /etc/kubernetes/admin.conf "$SHARED_DIR/admin.conf"
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy kubeconfig to $SHARED_DIR"
  exit 1
fi

# Install Calico
echo "Installing Calico CNI..."
export KUBECONFIG=/etc/kubernetes/admin.conf
su - $USER -c "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml"
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Calico."
  exit 1
fi

# Generate join command with longer token TTL
echo "Generating join command..."
kubeadm token create --print-join-command --ttl=24h > "$SHARED_DIR/join-command.sh"
if [ $? -ne 0 ]; then
  echo "Error: Failed to generate join command."
  exit 1
fi
chmod +x "$SHARED_DIR/join-command.sh"

echo "Master node setup complete. Join command saved to $SHARED_DIR/join-command.sh"
