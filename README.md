
# Windows Docker Container Setup Script

This project provides a Bash script to create and run a Docker container with various Windows versions. The script allows for the customization of the container's RAM size, CPU cores, disk size, machine name, and ports. It also includes a check to ensure Docker is installed and installs it if necessary.

## Features

- Choose from a variety of Windows versions (e.g., Windows 11 Pro, Windows 10 LTSC, Tiny 11, etc.).
- Customize RAM size, CPU cores, and disk size for the container.
- Set custom machine name, username, and password.
- Specify RDP and VNC ports, with automatic checks to ensure the ports are available.
- Auto-creation of storage volume directories.
- Automatically installs Docker if it is not already installed.
- Includes the necessary volume mappings, including a custom `./oem` directory.

## Prerequisites

- **Operating System:** Ubuntu (or any Linux distribution that supports Docker).
- **Docker:** The script will check for Docker and install it if necessary.

## Usage

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/windows-docker-setup.git
   cd windows-docker-setup
   ```

2. **Make the script executable:**

   ```bash
   chmod +x setup-windows-container.sh
   ```

3. **Run the script with options:**

   ```bash
   ./setup-windows-container.sh [-r RAM_SIZE] [-c CPU_CORES] [-d DISK_SIZE] [-m MACHINE_NAME] [-u USERNAME] [-p PASSWORD] [-R RDP_PORT] [-v VNC_PORT] [-h]
   ```

**Example:**

   ```bash
   ./setup-windows-container.sh -r 8 -c 4 -d 64 -m MyMachine -u admin -p mypassword -R 3389 -v 5900
   ```

### Command-Line Options

- `-r RAM_SIZE`: Set the RAM size (e.g., `4` for `4G`).
- `-c CPU_CORES`: Set the number of CPU cores (e.g., `2`).
- `-d DISK_SIZE`: Set the disk size (e.g., `64` for `64G`).
- `-m MACHINE_NAME`: Set the machine name.
- `-u USERNAME`: Set the username.
- `-p PASSWORD`: Set the password.
- `-R RDP_PORT`: Set the RDP port (default: `3389`).
- `-v VNC_PORT`: Set the VNC port (default: `8006`).
- `-h`: Display help message.

## Windows Versions Available

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

## Example Run

```bash
./setup-windows-container.sh -r 8 -c 4 -d 64 -m MyMachine -u admin -p mypassword -R 3390 -v 5901
```

This command will set up a Docker container running Windows 10 Pro (`win10`), with 8GB of RAM, 4 CPU cores, a 64GB disk, and use RDP port `3390` and VNC port `5901`.

## Acknowledgments

This project is based on [dockur/windows](https://github.com/dockur/windows/tree/master). Huge thanks to the original creator for their work!

## Contributing

Feel free to submit issues or pull requests if you find any bugs or want to add features.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

You can now use this as the `README.md` file in your GitHub repository.
