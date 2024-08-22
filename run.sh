#!/bin/bash

DEFAULT_RAM_SIZE="14"
DEFAULT_CPU_CORES="6"
DEFAULT_DISK_SIZE="64"

RAM_SIZE=""
CPU_CORES=""
DISK_SIZE=""
USERNAME=""
PASSWORD=""
MACHINE_NAME=""
RDP_PORT=""
VNC_PORT=""

# Function to install Docker
install_docker() {
    echo "Docker not found. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    echo "Docker installed successfully!"
}

# Check the distro and warn if not Ubuntu
DISTRO=$(lsb_release -is)
if [[ $DISTRO != "Ubuntu" ]]; then
    echo "This script is designed to run on Ubuntu. Proceeding might not work as expected."
    read -p "Do you want to continue? (y/n): " choice
    if [[ "$choice" != "y" ]]; then
        echo "Exiting script."
        exit 1
    fi
fi

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
        -r) RAM_SIZE="${2}G"; shift ;;
        -c) CPU_CORES="$2"; shift ;;
        -d) DISK_SIZE="${2}G"; shift ;;
        -u) USERNAME="$2"; shift ;;
        -p) PASSWORD="$2"; shift ;;
        -m) MACHINE_NAME="$2"; shift ;;
        -R) RDP_PORT="$2"; shift ;;
        -v) VNC_PORT="$2"; shift ;;
        *) echo "Unknown option $1"; exit 1 ;;
    esac
    shift
done

# Prompt for missing values
[[ -z "$RAM_SIZE" ]] && read -p "Enter RAM size (e.g., 14): " RAM_SIZE && RAM_SIZE="${RAM_SIZE}G"
[[ -z "$CPU_CORES" ]] && read -p "Enter number of CPU cores (e.g., 6): " CPU_CORES
[[ -z "$DISK_SIZE" ]] && read -p "Enter disk size (e.g., 64): " DISK_SIZE && DISK_SIZE="${DISK_SIZE}G"
[[ -z "$MACHINE_NAME" ]] && read -p "Enter machine name: " MACHINE_NAME
[[ -z "$USERNAME" ]] && read -p "Enter username: " USERNAME
[[ -z "$PASSWORD" ]] && read -p "Enter password: " PASSWORD
[[ -z "$RDP_PORT" ]] && read -p "Enter RDP port: " RDP_PORT
[[ -z "$VNC_PORT" ]] && read -p "Enter VNC port: " VNC_PORT

# Set up container and volume names
CONTAINER_NAME="${MACHINE_NAME}-${RDP_PORT}-${VNC_PORT}"
VOLUME_PATH="/root/windows/${CONTAINER_NAME}"

# Create the volume directory if it doesn't exist
if [ ! -d "$VOLUME_PATH" ]; then
    mkdir -p "$VOLUME_PATH"
fi

echo "Verifying Docker installation..."
if ! command -v docker &> /dev/null; then
    install_docker
fi

echo "Running the Docker container..."
docker run -d \
    -p "${RDP_PORT}:3389/tcp" -p "${RDP_PORT}:3389/udp" -p "${VNC_PORT}:8006" \
    -v "${VOLUME_PATH}:/storage" \
    -v "./oem:/oem" \
    --device=/dev/kvm --cap-add NET_ADMIN \
    -e VERSION="" -e RAM_SIZE="$RAM_SIZE" -e CPU_CORES="$CPU_CORES" \
    -e DISK_SIZE="$DISK_SIZE" -e USERNAME="$USERNAME" -e PASSWORD="$PASSWORD" \
    --name "$CONTAINER_NAME" --restart always dockurr/windows

EXTERNAL_IP=$(curl -s ifconfig.me)
echo "All done! You can access VNC via ${EXTERNAL_IP}:${VNC_PORT} or access RDP via ${EXTERNAL_IP}:${RDP_PORT}."
