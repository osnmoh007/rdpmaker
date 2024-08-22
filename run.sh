#!/bin/bash

# Default values
DEFAULT_RAM_SIZE="14G"
DEFAULT_CPU_CORES="6"
DEFAULT_DISK_SIZE="64G"
RAM_SIZE=""
CPU_CORES=""
DISK_SIZE=""
USERNAME=""
PASSWORD=""
MACHINE_NAME=""
RDP_PORT=""
VNC_PORT=""
VERSION=""

# Function to check if a port is in use
check_port() {
    local PORT=$1
    if sudo netstat -tuln | grep -q ":$PORT"; then
        return 1  # Port is in use
    else
        return 0  # Port is free
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 [-r RAM_SIZE] [-c CPU_CORES] [-d DISK_SIZE] [-u USERNAME] [-p PASSWORD] [-m MACHINE_NAME] [-R RDP_PORT] [-v VNC_PORT] [-V VERSION]"
    echo "  -r  RAM_SIZE       Set RAM size (e.g., 14 for 14G)"
    echo "  -c  CPU_CORES      Set the number of CPU cores (e.g., 6)"
    echo "  -d  DISK_SIZE      Set the disk size (e.g., 64)"
    echo "  -u  USERNAME       Set the username for the Windows machine"
    echo "  -p  PASSWORD       Set the password for the Windows machine"
    echo "  -m  MACHINE_NAME   Set the machine name"
    echo "  -R  RDP_PORT       Set the RDP port"
    echo "  -v  VNC_PORT       Set the VNC port"
    echo "  -V  VERSION        Set the Windows version (e.g., win11, win10)"
    exit 1
}

# Check if the distro is Ubuntu
if [[ "$(lsb_release -is)" != "Ubuntu" ]]; then
    echo "This script is designed to run on Ubuntu. It may not work properly on other distributions."
    read -p "Do you want to proceed? (y/n): " proceed
    if [[ "$proceed" != "y" ]]; then
        exit 1
    fi
fi

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r) RAM_SIZE="${2}G"; shift ;;
        -c) CPU_CORES="$2"; shift ;;
        -d) DISK_SIZE="${2}G"; shift ;;
        -u) USERNAME="$2"; shift ;;
        -p) PASSWORD="$2"; shift ;;
        -m) MACHINE_NAME="$2"; shift ;;
        -R) RDP_PORT="$2"; shift ;;
        -v) VNC_PORT="$2"; shift ;;
        -V) VERSION="$2"; shift ;;
        -h) usage ;;
        *) usage ;;
    esac
    shift
done

# Prompt for missing values
if [[ -z "$RAM_SIZE" ]]; then
    read -p "Enter RAM size (e.g., 14 for 14G): " RAM_SIZE
    RAM_SIZE="${RAM_SIZE}G"
fi

if [[ -z "$CPU_CORES" ]]; then
    read -p "Enter number of CPU cores (e.g., 6): " CPU_CORES
fi

if [[ -z "$DISK_SIZE" ]]; then
    read -p "Enter disk size in GB (e.g., 64): " DISK_SIZE
    DISK_SIZE="${DISK_SIZE}G"
fi

if [[ -z "$USERNAME" ]]; then
    read -p "Enter username: " USERNAME
fi

if [[ -z "$PASSWORD" ]]; then
    read -sp "Enter password: " PASSWORD; echo
fi

if [[ -z "$MACHINE_NAME" ]]; then
    read -p "Enter machine name: " MACHINE_NAME
fi

if [[ -z "$RDP_PORT" ]]; then
    read -p "Enter RDP port: " RDP_PORT
fi

if [[ -z "$VNC_PORT" ]]; then
    read -p "Enter VNC port: " VNC_PORT
fi

# Define Windows version codes
declare -A WINDOWS_VERSIONS=(
    [1]="win11"
    [2]="win11e"
    [3]="win10"
    [4]="ltsc10"
    [5]="win10e"
    [6]="win8"
    [7]="win8e"
    [8]="win7"
    [9]="vista"
    [10]="winxp"
    [11]="2022"
    [12]="2019"
    [13]="2016"
    [14]="2012"
    [15]="2008"
    [16]="core11"
    [17]="tiny11"
    [18]="tiny10"
)

# Prompt for Windows version if not provided
if [[ -z "$VERSION" ]]; then
    echo "Available Windows versions:"
    for i in "${!WINDOWS_VERSIONS[@]}"; do
        echo "$i) ${WINDOWS_VERSIONS[$i]}"
    done

    while true; do
        read -p "Enter the number for the Windows version you want to use: " choice
        VERSION="${WINDOWS_VERSIONS[$choice]}"
        
        if [[ -z "$VERSION" ]]; then
            echo "Invalid choice. Please select a valid Windows version."
        else
            break
        fi
    done
fi

# Check for Docker installation
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."

    # Update the package repository
    echo "Updating package repository..."
    sudo apt-get update -y

    # Install required packages
    echo "Installing required packages..."
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    echo "Adding Docker's official GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the stable repository
    echo "Setting up the Docker stable repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the package repository again
    echo "Updating package repository..."
    sudo apt-get update -y

    # Install Docker Engine
    echo "Installing Docker Engine..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "Docker installation complete."
else
    echo "Docker is already installed."
fi

# Create a unique container name using machine name, RDP port, and VNC port
CONTAINER_NAME="${MACHINE_NAME}-${RDP_PORT}-${VNC_PORT}"

# Define volume path based on container name
VOLUME_PATH="/root/windows/$CONTAINER_NAME"

# Create the directory if it doesn't exist
if [ ! -d "$VOLUME_PATH" ]; then
    echo "Creating volume directory: $VOLUME_PATH"
    mkdir -p "$VOLUME_PATH"
fi

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version

# Run the Docker container with the specified parameters
echo "Running the Docker container..."
docker run -d \
    -p $RDP_PORT:3389/tcp \
    -p $RDP_PORT:3389/udp \
    -p $VNC_PORT:8006 \
    -v "$VOLUME_PATH:/storage" \
    -v "./oem:/oem" \
    --device=/dev/kvm \
    --cap-add NET_ADMIN \
    -e VERSION="$VERSION" \
    -e RAM_SIZE="$RAM_SIZE" \
    -e CPU_CORES="$CPU_CORES" \
    -e DISK_SIZE="$DISK_SIZE" \
    -e USERNAME="$USERNAME" \
    -e PASSWORD="$PASSWORD" \
    --name "$CONTAINER_NAME" \
    --restart always \
    dockurr/windows

echo "All done! You can access VNC via $(curl -s ifconfig.me):$VNC_PORT or access RDP via $(curl -s ifconfig.me):$RDP_PORT."
