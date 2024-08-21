

# 🪟 Windows Docker Container Setup Script 🚀

Welcome to the Windows Docker Container Setup Script! This project provides a Bash script to create and run a Docker container with various Windows versions. Customize your container's RAM size, CPU cores, disk size, machine name, and ports effortlessly.

## ✨ Features

- 🎨 Choose from a variety of Windows versions (e.g., Windows 11 Pro, Windows 10 LTSC, Tiny 11, etc.).
- 🛠 Customize RAM size, CPU cores, and disk size for your container.
- 🖥 Set custom machine name, username, and password.
- 🔐 Specify RDP and VNC ports, with automatic checks to ensure availability.
- 📂 Auto-create storage volume directories.
- 🐳 Automatically installs Docker if it's not already installed.
- 📁 Includes necessary volume mappings, including a custom `./oem` directory.

## 📋 Prerequisites

- **Operating System:** Ubuntu .
- **Docker:** The script will check for Docker and install it if necessary.
> **Note:** This script is designed to run on Ubuntu. Other Linux distributions may require modifications.

## 🏃 Usage

1. **Clone the repository:**

   ```bash
   git clone https://github.com/osnmoh007/rdpmaker.git
   cd rdpmaker
   ```

2. **Make the script executable:**

   ```bash
   chmod +x run.sh
   ```

3. **Run the script with or without options:**

   You can either use flags to specify the options directly or let the script prompt you interactively.

   **Using Flags:**

   ```bash
   ./run.sh [-r RAM_SIZE] [-c CPU_CORES] [-d DISK_SIZE] [-m MACHINE_NAME] [-u USERNAME] [-p PASSWORD] [-R RDP_PORT] [-v VNC_PORT] [-h]
   ```

   **Without Flags:**

   If you run the script without flags, you'll be prompted to enter the options interactively.

## 🛠 Command-Line Options

- `-r RAM_SIZE`: Set the RAM size (e.g., `4` for `4G`).
- `-c CPU_CORES`: Set the number of CPU cores (e.g., `2`).
- `-d DISK_SIZE`: Set the disk size (e.g., `64` for `64G`).
- `-m MACHINE_NAME`: Set the machine name.
- `-u USERNAME`: Set the username.
- `-p PASSWORD`: Set the password.
- `-R RDP_PORT`: Set the RDP port (default: `3389`).
- `-v VNC_PORT`: Set the VNC port (default: `8006`).
- `-h`: Display help message.

## 📑 Example

```bash
./run.sh -r 8 -c 4 -d 64 -m MyMachine -u admin -p mypassword -R 3390 -v 5901
```

This command will set up a Docker container running Windows 10 Pro (`win10`), with 8GB of RAM, 4 CPU cores, a 64GB disk, and use RDP port `3390` and VNC port `5901`.

## 🖥 Available Windows Versions

- `win11`: Windows 11 Pro
- `win11e`: Windows 11 Enterprise
- `win10`: Windows 10 Pro
- `ltsc10`: Windows 10 LTSC
- `win10e`: Windows 10 Enterprise
- `win8`: Windows 8.1 Pro
- `win8e`: Windows 8.1 Enterprise
- `win7`: Windows 7 Enterprise
- `vista`: Windows Vista Enterprise
- `winxp`: Windows XP Professional
- `2022`: Windows Server 2022
- `2019`: Windows Server 2019
- `2016`: Windows Server 2016
- `2012`: Windows Server 2012
- `2008`: Windows Server 2008
- `core11`: Tiny 11 Core
- `tiny11`: Tiny 11
- `tiny10`: Tiny 10

## 🙌 Acknowledgments

This project is based on [dockur/windows](https://github.com/dockur/windows/tree/master). Huge thanks to the original creator for their work!

Special thanks to ChatGPT for the support and assistance throughout this project.

## 📄 License

This project is licensed under the MIT License.

## 📞 Contact

Feel free to reach out if you have any questions or need assistance:
- Telegram: [@mohfreestyl](https://t.me/mohfreestyl)
- Website Contact Form: [mohamedmaamir.com](https://mohamedmaamir.com)

