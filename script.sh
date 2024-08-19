#!/bin/bash

# Default values
DEFAULT_RAM_SIZE="14G"
DEFAULT_CPU_CORES="6"
RAM_SIZE=$DEFAULT_RAM_SIZE
CPU_CORES=$DEFAULT_CPU_CORES

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
    echo "Usage: $0 [-ram RAM_SIZE] [-cpu CPU_CORES]"
    echo "  -ram  RAM_SIZE       Set RAM size (e.g., 4 for 4G)"
    echo "  -cpu  CPU_CORES      Set the number of CPU cores (e.g., 2)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -ram) RAM_SIZE="${2}G"; shift ;;
        -cpu) CPU_CORES="$2"; shift ;;
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
read -p "Enter the machine name: " MACHINE_NAME
read -p "Enter the username: " USERNAME
read -sp "Enter the password: " PASSWORD
echo

# Prompt for RDP port and VNC port, and check for availability
while true; do
    read -p "Enter the RDP port: " RDP_PORT
    read -p "Enter the VNC port: " VNC_PORT

    # Check the availability of RDP port
    if ! check_port $RDP_PORT; then
        echo "RDP port $RDP_PORT is already in use. Please choose a different port."
        continue
    fi

    # Check the availability of VNC port
    if ! check_port $VNC_PORT; then
        echo "VNC port $VNC_PORT is already in use. Please choose a different port."
        continue
    fi

    break
done

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
    --stop-timeout 120 \
    -e VERSION="$WINDOWS_CODE" \
    -e RAM_SIZE="$RAM_SIZE" \
    -e CPU_CORES="$CPU_CORES" \
    -e USERNAME="$USERNAME" \
    -e PASSWORD="$PASSWORD" \
    --name "$CONTAINER_NAME" \
    dockurr/windows

echo "Script execution complete."
