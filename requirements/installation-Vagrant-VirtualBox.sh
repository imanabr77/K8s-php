#!/bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo."
    exit 1
fi

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "ERROR: Could not detect the Linux distribution."
    exit 1
fi

# Function to install VirtualBox
install_virtualbox() {
    case $OS in
        "ubuntu" | "debian")
            echo "Installing VirtualBox for Ubuntu/Debian..."
            apt update
            apt install -y virtualbox virtualbox-ext-pack
	    apt install -y linux-headers-$(uname -r) dkms
            systemctl enable virtualbox.service
            systemctl restart virtualbox
    	    systemctl status virtualbox
            ;;
        "centos" | "rhel")
            echo "Installing VirtualBox for CentOS/RHEL..."
            yum install -y epel-release
            yum install -y VirtualBox
            ;;
        "fedora")
            echo "Installing VirtualBox for Fedora..."
            dnf install -y VirtualBox
            ;;
        *)
            echo "ERROR: Unsupported OS for VirtualBox installation."
            exit 1
            ;;
    esac
}

# Function to install Vagrant
install_vagrant() {
    case $OS in
        "ubuntu" | "debian")
            echo "Installing Vagrant for Ubuntu/Debian..."
            curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            apt update
            apt install -y vagrant
            ;;
        "centos" | "rhel" | "fedora")
            echo "Installing Vagrant for CentOS/RHEL/Fedora..."
            if [ "$OS" = "fedora" ]; then
                dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
                dnf install -y vagrant
            else
                yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
                yum install -y vagrant
            fi
            ;;
        *)
            echo "ERROR: Unsupported OS for Vagrant installation."
            exit 1
            ;;
    esac
}

# Main installation
echo "Starting installation of VirtualBox and Vagrant..."
install_virtualbox
install_vagrant

# Verify installations
if command -v VBoxManage &> /dev/null && command -v vagrant &> /dev/null; then
    echo "SUCCESS: VirtualBox and Vagrant installed successfully!"
    echo "VirtualBox version: $(VBoxManage --version)"
    echo "Vagrant version: $(vagrant --version)"
else
    echo "ERROR: Installation failed. Check logs above."
    exit 1
fi

# Add user to vboxusers group (required for VirtualBox)
if id "$SUDO_USER" &> /dev/null; then
    usermod -aG vboxusers "$SUDO_USER"
    echo "NOTE: User '$SUDO_USER' added to 'vboxusers' group. Log out and back in for changes to apply."
else
    echo "WARNING: Could not add user to 'vboxusers' group (user not found)."
fi

echo "Installation complete! Test with:"
echo "  vagrant init ubuntu/focal64 && vagrant up"
