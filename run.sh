#!/bin/bash

# Default values
DEFAULT_RAM_SIZE=14
DEFAULT_CPU_CORES=6
DEFAULT_DISK_SIZE=64
DEFAULT_USER="admin"
DEFAULT_PASSWORD="password"
DEFAULT_MACHINE_NAME="default"
DEFAULT_RDP_PORT=3389
DEFAULT_VNC_PORT=8006

# Function to display usage
usage() {
    echo "Usage: $0 [-r RAM_SIZE] [-c CPU_CORES] [-d DISK_SIZE] [-u USERNAME] [-p PASSWORD] [-m MACHINE_NAME] [-R RDP_PORT] [-v VNC_PORT] [-V WINDOWS_VERSION]"
    echo "  -r  RAM_SIZE       Set RAM size (e.g., 14 for 14G)"
    echo "  -c  CPU_CORES      Set the number of CPU cores (e.g., 6)"
    echo "  -d  DISK_SIZE      Set the disk size (e.g., 64 for 64G)"
    echo "  -u  USERNAME       Set the username for the Windows machine"
    echo "  -p  PASSWORD       Set the password for the Windows machine"
    echo "  -m  MACHINE_NAME   Set the machine name"
    echo "  -R  RDP_PORT       Set the RDP port (numeric)"
    echo "  -v  VNC_PORT       Set the VNC port (numeric)"
    echo "  -V  WINDOWS_VERSION Set the Windows version (e.g., win11)"
    exit 1
}

# Function to check if a string is a valid number
is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Function to display available Windows versions
display_windows_versions() {
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
}

# Function to install Docker
install_docker() {
    DISTRO=$(lsb_release -is)
    echo "Installing Docker on $DISTRO system..."

    case "$DISTRO" in
        Ubuntu|Debian)
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl software-properties-common
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            apt-get update
            apt-get install -y docker-ce
            ;;
        CentOS)
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            yum install -y docker-ce
            ;;
        Fedora)
            dnf install -y dnf-plugins-core
            dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            dnf install -y docker-ce
            ;;
        Arch)
            pacman -Syu --noconfirm docker
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac

    systemctl start docker
    systemctl enable docker
    echo "Docker installed successfully."
}

# Parse command line arguments
while getopts ":r:c:d:u:p:m:R:v:V:" opt; do
    case ${opt} in
        r) RAM_SIZE="${OPTARG}" ;;
        c) CPU_CORES="${OPTARG}" ;;
        d) DISK_SIZE="${OPTARG}" ;;
        u) USERNAME="${OPTARG}" ;;
        p) PASSWORD="${OPTARG}" ;;
        m) MACHINE_NAME="${OPTARG}" ;;
        R) RDP_PORT="${OPTARG}" ;;
        v) VNC_PORT="${OPTARG}" ;;
        V) WINDOWS_VERSION="${OPTARG}" ;;
        \?) usage ;;
    esac
done
shift $((OPTIND -1))

# Check distro
DISTRO=$(lsb_release -is)
if [[ "$DISTRO" != "Ubuntu" ]]; then
    echo "This script is intended to run on Ubuntu. Proceeding might cause issues."
    read -p "Do you want to continue? (y/n) [default: y]: " choice
    choice=${choice:-y}  # Set default to 'y' if no input is provided
    case "$choice" in
        y|Y) ;;
        *) exit ;;
    esac
fi

# Prompt for missing values
if [[ -z "$RAM_SIZE" ]]; then
    read -p "Enter RAM size (e.g., 14 for 14G): " RAM_SIZE
fi

if ! is_number "$RAM_SIZE"; then
    echo "Invalid RAM_SIZE. Please enter a valid number."
    exit 1
fi

if [[ -z "$CPU_CORES" ]]; then
    read -p "Enter number of CPU cores (e.g., 6): " CPU_CORES
fi

if ! is_number "$CPU_CORES"; then
    echo "Invalid CPU_CORES. Please enter a valid number."
    exit 1
fi

if [[ -z "$DISK_SIZE" ]]; then
    read -p "Enter disk size (e.g., 64 for 64G): " DISK_SIZE
fi

if ! is_number "$DISK_SIZE"; then
    echo "Invalid DISK_SIZE. Please enter a number without 'G'."
    exit 1
fi

if [[ -z "$USERNAME" ]]; then
    read -p "Enter username for the Windows machine: " USERNAME
fi

if [[ -z "$PASSWORD" ]]; then
    read -s -p "Enter password for the Windows machine: " PASSWORD
    echo
fi

if [[ -z "$MACHINE_NAME" ]]; then
    read -p "Enter machine name: " MACHINE_NAME
fi

if [[ -z "$RDP_PORT" ]]; then
    read -p "Enter RDP port (numeric): " RDP_PORT
fi

if ! is_number "$RDP_PORT"; then
    echo "Invalid RDP_PORT. Please enter a numeric value."
    exit 1
fi

if [[ -z "$VNC_PORT" ]]; then
    read -p "Enter VNC port (numeric): " VNC_PORT
fi

if ! is_number "$VNC_PORT"; then
    echo "Invalid VNC_PORT. Please enter a numeric value."
    exit 1
fi

# Check Windows version
while [[ -z "$WINDOWS_VERSION" ]]; do
    display_windows_versions
    read -p "Enter the Windows version number (e.g., 1 for Windows 11): " VERSION_INPUT
    case "$VERSION_INPUT" in
        1) WINDOWS_VERSION="win11" ;;
        2) WINDOWS_VERSION="win11e" ;;
        3) WINDOWS_VERSION="win10" ;;
        4) WINDOWS_VERSION="ltsc10" ;;
        5) WINDOWS_VERSION="win10e" ;;
        6) WINDOWS_VERSION="win8" ;;
        7) WINDOWS_VERSION="win8e" ;;
        8) WINDOWS_VERSION="win7" ;;
        9) WINDOWS_VERSION="vista" ;;
        10) WINDOWS_VERSION="winxp" ;;
        11) WINDOWS_VERSION="2022" ;;
        12) WINDOWS_VERSION="2019" ;;
        13) WINDOWS_VERSION="2016" ;;
        14) WINDOWS_VERSION="2012" ;;
        15) WINDOWS_VERSION="2008" ;;
        16) WINDOWS_VERSION="core11" ;;
        17) WINDOWS_VERSION="tiny11" ;;
        18) WINDOWS_VERSION="tiny10" ;;
        *)
            echo "Invalid version number. Please try again."
            WINDOWS_VERSION=""
            ;;
    esac
done

# Validate Windows version
case "$WINDOWS_VERSION" in
    win11|win11e|win10|ltsc10|win10e|win8|win8e|win7|vista|winxp|2022|2019|2016|2012|2008|core11|tiny11|tiny10)
        ;;
    *)
        echo "Invalid version number. Please run the script again and select a valid version."
        exit 1
        ;;
esac

# Set default values if not provided
RAM_SIZE=${RAM_SIZE:-$DEFAULT_RAM_SIZE}
CPU_CORES=${CPU_CORES:-$DEFAULT_CPU_CORES}
DISK_SIZE=${DISK_SIZE:-$DEFAULT_DISK_SIZE}
USERNAME=${USERNAME:-$DEFAULT_USER}
PASSWORD=${PASSWORD:-$DEFAULT_PASSWORD}
MACHINE_NAME=${MACHINE_NAME:-$DEFAULT_MACHINE_NAME}
RDP_PORT=${RDP_PORT:-$DEFAULT_RDP_PORT}
VNC_PORT=${VNC_PORT:-$DEFAULT_VNC_PORT}

# Create volume directory
CONTAINER_NAME="${MACHINE_NAME}-${RDP_PORT}-${VNC_PORT}"
VOLUME_PATH="/root/windows/${CONTAINER_NAME}"
mkdir -p "${VOLUME_PATH}"

# Verify Docker installation
if ! command -v docker &> /dev/null; then
    install_docker
fi

# Run Docker container
echo "Running the Docker container..."
docker run -d \
    -p "${RDP_PORT}:3389/tcp" \
    -p "${RDP_PORT}:3389/udp" \
    -p "${VNC_PORT}:8006" \
    -v "${VOLUME_PATH}:/storage" \
    -v ./oem:/oem \
    --device=/dev/kvm \
    --cap-add NET_ADMIN \
    -e VERSION="${WINDOWS_VERSION}" \
    -e RAM_SIZE="${RAM_SIZE}G" \
    -e CPU_CORES="${CPU_CORES}" \
    -e DISK_SIZE="${DISK_SIZE}G" \
    -e USERNAME="${USERNAME}" \
    -e PASSWORD="${PASSWORD}" \
    --name "${CONTAINER_NAME}" \
    --restart always \
    dockurr/windows

# Check if Docker command was successful
if [ $? -ne 0 ]; then
    echo "Failed to run the Docker container."
    exit 1
fi

# Display external IP
EXTERNAL_IP=$(curl -s ifconfig.me)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve external IP address."
    echo "You can see the installation progress on your web browser via the VNC port ${VNC_PORT} or access RDP via the RDP port ${RDP_PORT}."
else
    echo "All done! You can access VNC via ${EXTERNAL_IP}:${VNC_PORT} or access RDP via ${EXTERNAL_IP}:${RDP_PORT}."
fi
