# SysAdmin Configurations ⚙️

Configuration files and documentation for my hybrid infrastructure (Linux & Windows).

## Structure
- **/nginx**: Reverse proxy configurations for web traffic load balancing.
- **/dhcp**: ISC-DHCP-Server configuration for VLAN management.
- **/windows-server**: Documentation for Active Directory and GPO implementations via PowerShell.


## How to Install (only fedora 42)

### 1. Clone the installation file
```bash
wget https://raw.githubusercontent.com/Jov-glitch/sysadmin-configs/main/install.sh
```

### 2. Set Permissions
```bash
chmod +x install.sh
```

### 3. And install.

```bash
./install.sh
```

### Bonus: FastInstall

```bash
wget https://raw.githubusercontent.com/Jov-glitch/sysadmin-configs/main/install.sh
chmod +x install.sh
./install.sh
```
