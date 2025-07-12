#!/bin/bash

# Set user and shared directory (modify if not using Vagrant)
USER=${USER:-vagrant}
SHARED_DIR=${SHARED_DIR:-/vagrant}
KUBECONFIG_PATH="/home/$USER/.kube/config"

# Copy kubeconfig from shared directory
echo "Copying kubeconfig to worker node..."
mkdir -p /home/$USER/.kube
cp "$SHARED_DIR/admin.conf" "$KUBECONFIG_PATH"
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy kubeconfig from $SHARED_DIR/admin.conf"
  exit 1
fi
chown $USER:$USER "$KUBECONFIG_PATH"

# Set KUBECONFIG environment variable
echo "export KUBECONFIG=$KUBECONFIG_PATH" >> /home/$USER/.bashrc
echo "export KUBECONFIG=$KUBECONFIG_PATH" >> /root/.bashrc
source /home/$USER/.bashrc

# Join the cluster
echo "Joining the cluster..."
export KUBECONFIG=$KUBECONFIG_PATH
bash "$SHARED_DIR/join-command.sh" | tee /var/log/kubeadm-join.log
if [ $? -ne 0 ]; then
  echo "Error: Failed to join the cluster. Check /var/log/kubeadm-join.log for details."
  exit 1
fi

echo "Worker node setup complete."
