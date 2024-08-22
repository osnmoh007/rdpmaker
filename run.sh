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
    echo "Usage: $0 [-r RAM_SIZE] [-c CPU_CORES] [-d DISK_SIZE] [-u USERNAME] [-p PASSWORD] [-m MACHINE_NAME] [-R RDP_PORT] [-v VNC_PORT]"
    echo "  -r  RAM_SIZE       Set RAM size (e.g., 14 for 14G)"
    echo "  -c  CPU_CORES      Set the number of CPU cores (e.g., 6)"
    echo "  -d  DISK_SIZE      Set the disk size (e.g., 64 for 64G)"
    echo "  -u  USERNAME       Set the username for the Windows machine"
    echo "  -p  PASSWORD       Set the password for the Windows machine"
    echo "  -m  MACHINE_NAME   Set the machine name"
    echo "  -R  RDP_PORT       Set the RDP port"
    echo "  -v  VNC_PORT       Set the VNC port"
    exit 1
}

# Check the Linux distribution
DISTRO=$(lsb_release -is 2>/dev/null)
if [[ "$DISTRO" != "Ubuntu" ]]; then
    echo "Warning: This script is designed for Ubuntu. It may not work correctly on other distributions."
    read -p "Do you want to proceed? (y/n): " response
    if [[ "$response" != "y" ]]; then
        echo "Exiting..."
        exit 0
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
        *)
            echo "Error: Invalid flag $1"
            usage
            ;;
    esac
    shift
done

# Prompt for RAM size if not provided
if [ -z "$RAM_SIZE" ]; then
    read -p "Enter the RAM size (e.g., 14 for 14G): " RAM_SIZE
    RAM_SIZE="${RAM_SIZE}G"
fi

# Prompt for CPU cores if not provided
if [ -z "$CPU_CORES" ]; then
    read -p "Enter the number of CPU cores (e.g., 6): " CPU_CORES
fi

# Prompt for disk size if not provided
if [ -z "$DISK_SIZE" ]; then
    read -p "Enter the disk size (e.g., 64 for 64G): " DISK_SIZE
    DISK_SIZE="${DISK_SIZE}G"
fi

# Prompt for machine name if not provided
if [ -z "$MACHINE_NAME" ]; then
    read -p "Enter the machine name: " MACHINE_NAME
fi

# Prompt for username if not provided
if [ -z "$USERNAME" ]; then
    read -p "Enter the username: " USERNAME
fi

# Prompt for password if not provided
if [ -z "$PASSWORD" ]; then
    read -sp "Enter the password: " PASSWORD
    echo
fi

# Prompt for RDP port and VNC port if not provided
while [ -z "$RDP_PORT" ] || [ -z "$VNC_PORT" ]; do
    if [ -z "$RDP_PORT" ]; then
        read -p "Enter the RDP port: " RDP_PORT
        if ! check_port $RDP_PORT; then
            echo "RDP port $RDP_PORT is already in use. Please choose a different port."
            RDP_PORT=""
        fi
    fi

    if [ -z "$VNC_PORT" ]; then
        read -p "Enter the VNC port: " VNC_PORT
        if ! check_port $VNC_PORT; then
            echo "VNC port $VNC_PORT is already in use. Please choose a different port."
            VNC_PORT=""
        fi
    fi
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
    -v "./oem:/oem" \
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

# Display completion message with connection info
EXTERNAL_IP=$(curl -s ifconfig.me)
echo "All done! You can access VNC via ${EXTERNAL_IP}:${VNC_PORT} or access RDP via ${EXTERNAL_IP}:${RDP_PORT}."
