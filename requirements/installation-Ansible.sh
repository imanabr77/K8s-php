#!/bin/bash

# Ansible Installation Script
# Supports: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch Linux, macOS, and pip installations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error messages
error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

# Function to print success messages
success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Function to print info messages
info() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root or with sudo privileges."
    exit 1
fi

# Detect OS and distribution
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/redhat-release ]; then
        OS=$(cat /etc/redhat-release | cut -d ' ' -f 1)
        VER=$(cat /etc/redhat-release | cut -d ' ' -f 4)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi

    info "Detected OS: $OS, Version: $VER"
}

# Install Ansible on Debian/Ubuntu
install_debian() {
    info "Installing Ansible on Debian/Ubuntu..."

    # Add Ansible PPA
    if ! grep -q "ansible" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
        apt-get update
        apt-get install -y software-properties-common
        add-apt-repository --yes --update ppa:ansible/ansible
    fi

    # Install Ansible
    apt-get update
    apt-get install -y ansible

    success "Ansible installed successfully on Debian/Ubuntu"
}

# Install Ansible on RHEL/CentOS/Fedora
install_redhat() {
    info "Installing Ansible on RHEL/CentOS/Fedora..."

    # Install EPEL on CentOS/RHEL
    if [[ "$OS" == "CentOS" || "$OS" == "Red Hat Enterprise Linux" ]]; then
        yum install -y epel-release
    fi

    # Install Ansible
    yum install -y ansible

    success "Ansible installed successfully on RHEL/CentOS/Fedora"
}

# Install Ansible on Arch Linux
install_arch() {
    info "Installing Ansible on Arch Linux..."

    pacman -Sy --noconfirm ansible

    success "Ansible installed successfully on Arch Linux"
}

# Install Ansible on macOS
install_macos() {
    info "Installing Ansible on macOS..."

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        error "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi

    brew install ansible

    success "Ansible installed successfully on macOS"
}

# Install Ansible via pip
install_pip() {
    info "Installing Ansible via pip..."

    # Check if pip is installed
    if ! command -v pip3 &> /dev/null; then
        info "pip3 not found, installing pip..."
        if [[ "$OS" == "Debian" || "$OS" == "Ubuntu" ]]; then
            apt-get install -y python3-pip
        elif [[ "$OS" == "CentOS" || "$OS" == "Red Hat Enterprise Linux" || "$OS" == "Fedora" ]]; then
            yum install -y python3-pip
        elif [[ "$OS" == "Arch Linux" ]]; then
            pacman -Sy --noconfirm python-pip
        else
            error "Cannot install pip on this system automatically."
            exit 1
        fi
    fi

    pip3 install --upgrade pip
    pip3 install ansible

    success "Ansible installed successfully via pip"
}

# Main installation function
install_ansible() {
    detect_os

    case $OS in
        *Debian*|*Ubuntu*)
            install_debian
            ;;
        *RedHat*|*CentOS*|*Fedora*)
            install_redhat
            ;;
        *Arch*)
            install_arch
            ;;
        *Darwin*|*macOS*)
            install_macos
            ;;
        *)
            info "Unsupported OS detected. Trying to install via pip..."
            install_pip
            ;;
    esac

    # Verify installation
    if command -v ansible &> /dev/null; then
        ansible_version=$(ansible --version | head -n 1)
        success "Ansible installation completed: $ansible_version"
    else
        error "Ansible installation failed. Please check the logs."
        exit 1
    fi
}

# Execute installation
install_ansible
