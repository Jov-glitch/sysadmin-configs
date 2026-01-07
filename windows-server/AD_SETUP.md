# Windows Server 2022 Active Directory Setup

## Overview
Documentation of the AD DS deployment in the home laboratory environment.

### Specifications
- **OS:** Windows Server 2022 Standard
- **Role:** Domain Controller (DC)
- **Domain:** `corp.jessvega.local`

### Configuration Steps
1. **Static IP Assignment:**
   - IP: 192.168.100.5
   - DNS: 127.0.0.1 (Loopback for AD DNS)

2. **PowerShell Automation:**
   ```powershell
   Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
   Install-ADDSForest -DomainName "corp.jessvega.local" -InstallDns
   ```

### GPO Policies Implemented
- **Disable USB Storage:** `Computer Configuration > Policies > Admin Templates > System > Removable Storage Access`
- **Password Complexity:** Enforced 12 chars minimum.
