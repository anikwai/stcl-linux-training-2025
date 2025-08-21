# SSH Root Login Fix for Debian VM

**Server:** 192.168.16.194  
**OS:** Debian (OpenSSH_10.0p2 Debian-7)  
**Issue:** Permission denied when attempting root SSH login  
**Date:** August 18, 2025  

## Problem Description

SSH connection to root@192.168.16.194 fails with "Permission denied" error despite correct network connectivity and SSH service running. The verbose SSH output shows:

```
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: password
root@192.168.16.194's password: 
debug1: Authentications that can continue: publickey,password
Permission denied, please try again.
```

## Root Cause

Debian systems typically disable root SSH login by default for security reasons. The SSH daemon configuration likely contains one of these settings:
- `PermitRootLogin no`
- `PermitRootLogin prohibit-password`
- `#PermitRootLogin prohibit-password` (commented out, using default)

## Solution Steps

### Prerequisites
- Physical/console access to the Debian VM, OR
- SSH access with a regular user account that has sudo privileges

### Step 1: Access the Server
Connect to the server using one of these methods:
```bash
# Option A: Console access (direct VM access)
# Option B: SSH with regular user
ssh username@192.168.16.194
```

### Step 2: Edit SSH Configuration
Open the SSH daemon configuration file:
```bash
sudo nano /etc/ssh/sshd_config
```

### Step 3: Modify Root Login Setting
Find the line containing `PermitRootLogin` and change it to:
```bash
PermitRootLogin yes
```

**Before:**
```bash
#PermitRootLogin prohibit-password
```
**After:**
```bash
PermitRootLogin yes
```

### Step 4: Verify Password Authentication
Ensure password authentication is enabled:
```bash
PasswordAuthentication yes
```

### Step 5: Save Configuration
- **nano**: Press `Ctrl + X`, then `Y`, then `Enter`
- **vim**: Press `Esc`, type `:wq`, press `Enter`

### Step 6: Restart SSH Service
Apply the configuration changes:
```bash
sudo systemctl restart sshd
```

Alternative command:
```bash
sudo service ssh restart
```

### Step 7: Verify Service Status
Check that SSH service restarted successfully:
```bash
sudo systemctl status sshd
```

### Step 8: Test Connection
From the Windows client, test the SSH connection:
```powershell
ssh root@192.168.16.194
```

## Security Considerations

⚠️ **WARNING**: Enabling root SSH login with password authentication poses security risks.

### Recommended Secure Alternatives

#### Option 1: Use Regular User with Sudo (Recommended)
```bash
# Connect with regular user
ssh username@192.168.16.194

# Switch to root when needed
sudo su -
```

#### Option 2: SSH Key Authentication Only
1. Generate SSH key pair on Windows client:
```powershell
ssh-keygen -t ed25519 -C "admin@company.com"
```

2. Copy public key to server:
```powershell
ssh-copy-id root@192.168.16.194
```

3. Set SSH config to key-only authentication:
```bash
PermitRootLogin prohibit-password
PasswordAuthentication no
```

#### Option 3: IP Address Restrictions
Limit root access to specific IP addresses in `/etc/ssh/sshd_config`:
```bash
Match User root
    AllowUsers root@192.168.16.111
```

## Verification Commands

### Check SSH Configuration
```bash
# View current SSH configuration
sudo sshd -T | grep -i permitroot
sudo sshd -T | grep -i passwordauth

# Test SSH configuration syntax
sudo sshd -t
```

### Monitor SSH Logs
```bash
# Real-time SSH log monitoring
sudo tail -f /var/log/auth.log

# Check recent SSH attempts
sudo grep "ssh" /var/log/auth.log | tail -20
```

## Troubleshooting

### If SSH Service Fails to Start
```bash
# Check SSH service status
sudo systemctl status sshd

# View detailed logs
sudo journalctl -u sshd

# Test configuration file syntax
sudo sshd -t
```

### If Connection Still Fails
1. Verify firewall settings:
```bash
sudo ufw status
sudo iptables -L
```

2. Check if root account is locked:
```bash
sudo passwd -S root
```

3. Verify SSH is listening on port 22:
```bash
sudo netstat -tlnp | grep :22
```

## Configuration Backup

Before making changes, always backup the original configuration:
```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)
```

## Rollback Procedure

To revert changes:
```bash
# Restore from backup
sudo cp /etc/ssh/sshd_config.backup.YYYYMMDD /etc/ssh/sshd_config

# Or disable root login again
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart sshd
```

## Network Information

- **Server IP**: 192.168.16.194
- **Client IP**: 192.168.16.111
- **SSH Port**: 22 (default)
- **Network**: Wi-Fi interface
- **Connectivity**: Confirmed (ping successful, port 22 open)

## Additional Notes

- Server is running OpenSSH_10.0p2 Debian-7
- Host key: ssh-ed25519 SHA256:tYrW3r3MKUbGRwza9xQ90hU4QCAzJhN9b18gQPvY47w
- No SSH keys currently configured on client
- Password authentication is functional once root login is enabled

---
**Document created**: August 18, 2025  
**Last updated**: August 18, 2025  
**Author**: System Administrator  
