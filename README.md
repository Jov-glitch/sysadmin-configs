# SysAdmin Configurations ⚙️

Configuration files and documentation for my hybrid infrastructure (Linux & Windows).

## Structure
- **/nginx**: Reverse proxy configurations for web traffic load balancing.
- **/dhcp**: ISC-DHCP-Server configuration for VLAN management.
- **/windows-server**: Documentation for Active Directory and GPO implementations via PowerShell.


## How to Install (only fedora 42)

### 1. Clone the repository
```bash
sudo dnf install git
git clone https://github.com:Jov-glitch/sysadmin-configs.git
cd sysadmin-configs
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
sudo dnf install git
git clone https://github.com:Jov-glitch/sysadmin-configs.git
cd sysadmin-configs
chmod +x install.sh
./install.sh
```
