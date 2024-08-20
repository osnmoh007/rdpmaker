#!/bin/bash

# Default values
DEFAULT_RAM_SIZE="14G"
DEFAULT_CPU_CORES="6"
DEFAULT_DISK_SIZE="64G"
RAM_SIZE=$DEFAULT_RAM_SIZE
CPU_CORES=$DEFAULT_CPU_CORES
DISK_SIZE=$DEFAULT_DISK_SIZE

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
    echo "Usage: $0 [-r RAM_SIZE] [-c CPU_CORES] [-d DISK_SIZE] [-m MACHINE_NAME] [-u USERNAME] [-p PASSWORD] [-R RDP_PORT] [-v VNC_PORT] [-h]"
    echo "  -r  RAM_SIZE       Set RAM size (e.g., 4 for 4G)"
    echo "  -c  CPU_CORES      Set the number of CPU cores (e.g., 2)"
    echo "  -d  DISK_SIZE      Set the disk size (e.g., 64 for 64G)"
    echo "  -m  MACHINE_NAME   Set the machine name"
    echo "  -u  USERNAME       Set the username"
    echo "  -p  PASSWORD       Set the password"
    echo "  -R  RDP_PORT       Set the RDP port"
    echo "  -v  VNC_PORT       Set the VNC port"
    echo "  -h  Display this help message"
    exit 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r) RAM_SIZE="${2}G"; shift ;;
        -c) CPU_CORES="$2"; shift ;;
        -d) DISK_SIZE="${2}G"; shift ;;
        -m) MACHINE_NAME="$2"; shift ;;
        -u) USERNAME="$2"; shift ;;
        -p) PASSWORD="$2"; shift ;;
        -R) RDP_PORT="$2"; shift ;;
        -v) VNC_PORT="$2"; shift ;;
        -h) usage ;;
        *) usage ;;
    esac
    shift
done

# Check if Docker is installed
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

# Display available Windows versions
echo "Available Windows versions:"
echo "1) win11: Windows 11 Pro"
echo "2) win11e: Windows 11 Enterprise"
echo "3) win10: Windows 10 Pro"
echo "4) ltsc10: Windows 10 LTSC"
echo "5) win10e: Windows 10 Enterprise"
echo "6) win8: Windows 8.1 Pro"
echo "7) win8e: Windows 8.1 Enterprise"
echo "8) win7: Windows 7 Enterprise"
echo "9) vista: Windows Vista Enterprise"
echo "10) winxp: Windows XP Professional"
echo "11) 2022: Windows Server 2022"
echo "12) 2019: Windows Server 2019"
echo "13) 2016: Windows Server 2016"
echo "14) 2012: Windows Server 2012"
echo "15) 2008: Windows Server 2008"
echo "16) core11: Tiny 11 Core"
echo "17) tiny11: Tiny 11"
echo "18) tiny10: Tiny 10"

# Prompt for Windows version selection
while true; do
    read -p "Enter the number for the Windows version you want to use: " choice
    WINDOWS_CODE="${WINDOWS_VERSIONS[$choice]}"
    
    if [ -z "$WINDOWS_CODE" ]; then
        echo "Invalid choice. Please select a valid Windows version."
    else
        break
    fi
done

# Prompt for machine name, username, password, and ports
if [ -z "$MACHINE_NAME" ]; then
    read -p "Enter the machine name: " MACHINE_NAME
fi
if [ -z "$USERNAME" ]; then
    read -p "Enter the username: " USERNAME
fi
if [ -z "$PASSWORD" ]; then
    read -sp "Enter the password: " PASSWORD
    echo
fi

# Prompt for RDP port and VNC port, and check for availability
if [ -z "$RDP_PORT" ]; then
    while true; do
        read -p "Enter the RDP port: " RDP_PORT
        if ! check_port $RDP_PORT; then
            echo "RDP port $RDP_PORT is already in use. Please choose a different port."
            continue
        fi
        break
    done
fi

if [ -z "$VNC_PORT" ]; then
    while true; do
        read -p "Enter the VNC port: " VNC_PORT
        if ! check_port $VNC_PORT; then
            echo "VNC port $VNC_PORT is already in use. Please choose a different port."
            continue
        fi
        break
    done
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
    --device=/dev/kvm \
    --cap-add NET_ADMIN \
    -e VERSION="$WINDOWS_CODE" \
    -e RAM_SIZE="$RAM_SIZE" \
    -e CPU_CORES="$CPU_CORES" \
    -e DISK_SIZE="$DISK_SIZE" \
    -e USERNAME="$USERNAME" \
    -e PASSWORD="$PASSWORD" \
    --name "$CONTAINER_NAME" \
    --restart always \
    dockurr/windows

echo "Script execution complete."
