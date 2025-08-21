# Enabling SELinux in Enforcing Mode on RHEL - Complete Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Understanding SELinux States](#understanding-selinux-states)
3. [Checking Current SELinux Status](#checking-current-selinux-status)
4. [Method 1: Runtime Configuration](#method-1-runtime-configuration)
5. [Method 2: Persistent Configuration](#method-2-persistent-configuration)
6. [Complete Step-by-Step Process](#complete-step-by-step-process)
7. [Verification Steps](#verification-steps)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)
10. [Common Issues and Solutions](#common-issues-and-solutions)

---

## Prerequisites

### System Requirements
- **Operating System**: Red Hat Enterprise Linux (RHEL) 7, 8, 9, or compatible (CentOS, AlmaLinux, Rocky Linux)
- **User Privileges**: Root access or sudo privileges
- **Kernel Support**: SELinux-enabled kernel (default in RHEL)

### Important Warning
⚠️ **CRITICAL**: Enabling SELinux on a production system can break applications. Always test in a development environment first!

---

## Understanding SELinux States

SELinux has **three operational modes**:

| Mode | Description | Use Case |
|------|-------------|----------|
| **Enforcing** | Policies enforced, violations blocked | Production systems |
| **Permissive** | Policies logged but not enforced | Testing and development |
| **Disabled** | SELinux completely turned off | Legacy applications |

---

## Checking Current SELinux Status

### Step 1: Check SELinux Status
```bash
# Check current SELinux status
sestatus

# Alternative short check
getenforce

# Check SELinux configuration file
cat /etc/selinux/config
```

**Expected Output Examples:**
```bash
# If SELinux is disabled
$ sestatus
SELinux status:                 disabled

# If SELinux is enabled
$ sestatus
SELinux status:                 enabled
SELinuxfs mount:               /sys/fs/selinux
SELinux root directory:        /etc/selinux
Loaded policy name:            targeted
Current mode:                  permissive
Mode from config file:         enforcing
Policy from config file:       targeted
```

---

## Method 1: Runtime Configuration (Temporary)

### For Testing Purposes Only

```bash
# Switch from permissive to enforcing (temporary)
sudo setenforce 1

# Switch from enforcing to permissive (temporary)
sudo setenforce 0

# Check current mode
getenforce
```

**Note**: Runtime changes are **temporary** and reset after reboot.

---

## Method 2: Persistent Configuration (Recommended)

### Modify SELinux Configuration File

```bash
# Backup the original configuration
sudo cp /etc/selinux/config /etc/selinux/config.backup

# Edit the configuration file
sudo vim /etc/selinux/config
```

**Configuration File Content:**
```bash
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing

# SELINUXTYPE= can take one of these values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

---

## Complete Step-by-Step Process

### Scenario 1: SELinux is Currently Disabled

#### Step 1: Check Current Status
```bash
# Verify SELinux is disabled
sestatus
getenforce
```

#### Step 2: Modify Configuration File
```bash
# Backup current configuration
sudo cp /etc/selinux/config /etc/selinux/config.backup.$(date +%Y%m%d_%H%M%S)

# Edit configuration
sudo sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config

# Verify the change
grep SELINUX /etc/selinux/config
```

#### Step 3: Install SELinux Packages (if missing)
```bash
# Install required packages
sudo yum install -y policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted

# For RHEL 8/9, use dnf instead of yum
sudo dnf install -y policycoreutils policycoreutils-python-utils selinux-policy selinux-policy-targeted
```

#### Step 4: Create /.autorelabel File
```bash
# Force filesystem relabeling on next boot
sudo touch /.autorelabel
```

#### Step 5: Reboot System
```bash
# Reboot to enable SELinux
sudo reboot
```

**Important**: The first boot will take longer as SELinux relabels all files.

---

### Scenario 2: SELinux is Currently in Permissive Mode

#### Step 1: Check Current Status
```bash
sestatus
getenforce  # Should show "Permissive"
```

#### Step 2: Switch to Enforcing (Runtime)
```bash
# Temporarily switch to enforcing for testing
sudo setenforce 1
getenforce  # Should show "Enforcing"
```

#### Step 3: Test Applications
```bash
# Test critical services
sudo systemctl status httpd
sudo systemctl status sshd
sudo systemctl status NetworkManager

# Check for SELinux denials
sudo ausearch -m avc -ts recent
```

#### Step 4: Make Persistent (if tests pass)
```bash
# Update configuration file
sudo sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config

# Verify configuration
grep SELINUX /etc/selinux/config
```

#### Step 5: Reboot (recommended)
```bash
sudo reboot
```

---

### Scenario 3: SELinux is Already in Enforcing Mode

#### Verification Steps
```bash
# Confirm SELinux is in enforcing mode
sestatus
getenforce  # Should show "Enforcing"

# Check configuration file
cat /etc/selinux/config | grep SELINUX=
```

✅ **No action needed** - SELinux is already configured correctly.

---

## Verification Steps

### Post-Configuration Verification

#### Step 1: Verify SELinux Status
```bash
# Comprehensive status check
sestatus -v

# Quick mode check
getenforce

# Check configuration matches runtime
sestatus | grep -E "(Current mode|Mode from config)"
```

#### Step 2: Verify Services are Running
```bash
# Check critical services
sudo systemctl status sshd
sudo systemctl status NetworkManager
sudo systemctl status firewalld

# If running web server
sudo systemctl status httpd
sudo systemctl status nginx
```

#### Step 3: Check for SELinux Denials
```bash
# Check recent AVC denials
sudo ausearch -m avc -ts today

# Check audit log for SELinux messages
sudo tail -f /var/log/audit/audit.log | grep -i selinux

# Check system messages
sudo journalctl | grep -i selinux
```

#### Step 4: Test File Contexts
```bash
# Check file contexts in common directories
ls -Z /etc/passwd
ls -Z /var/www/html/
ls -Z /home/

# Check process contexts
ps -eZ | head -10
```

---

## Troubleshooting

### Common Issues During Enablement

#### Issue 1: Boot Failures After Enabling SELinux

**Symptoms:**
- System fails to boot
- Services don't start
- SSH access denied

**Solution:**
```bash
# Boot into rescue mode or single-user mode
# Add to kernel parameters: selinux=0

# At GRUB menu, press 'e' to edit
# Add 'selinux=0' to the kernel line
# Boot with Ctrl+X

# Once booted, fix SELinux contexts
sudo restorecon -R /

# Re-enable SELinux
sudo setenforce 1
```

#### Issue 2: SSH Access Denied

**Symptoms:**
```
SELinux is preventing /usr/sbin/sshd from binding name to port 22
```

**Solution:**
```bash
# Check SSH context
sudo setsebool -P ssh_sysadm_login 1

# Restore SSH contexts
sudo restorecon -R /etc/ssh/
sudo restorecon -R /var/empty/sshd/

# Check SSH port context
sudo semanage port -l | grep ssh
```

#### Issue 3: Web Server Issues

**Symptoms:**
- HTTP 403 Forbidden errors
- Web server can't read files

**Solution:**
```bash
# Set proper web server contexts
sudo setsebool -P httpd_enable_homedirs 1
sudo setsebool -P httpd_read_user_content 1

# Fix web root contexts
sudo restorecon -R /var/www/
sudo semanage fcontext -a -t httpd_exec_t "/var/www/cgi-bin(/.*)?"
sudo restorecon -R /var/www/cgi-bin/
```

---

## Best Practices

### 1. Gradual Enablement Process
```bash
# Step 1: Enable in permissive mode first
sudo sed -i 's/SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
sudo reboot

# Step 2: Monitor for 24-48 hours
sudo ausearch -m avc -ts today

# Step 3: Switch to enforcing if no critical denials
sudo setenforce 1

# Step 4: Make persistent after testing
sudo sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
```

### 2. Essential SELinux Management Commands
```bash
# Status and mode management
sestatus                    # Comprehensive status
getenforce                  # Current mode
setenforce [0|1]           # Runtime mode change

# Context management
ls -Z                       # List file contexts
ps -eZ                     # List process contexts
restorecon -R /path        # Restore default contexts
chcon -t type_t file       # Change file context

# Policy management
getsebool -a               # List all booleans
setsebool bool_name on     # Set boolean (temporary)
setsebool -P bool_name on  # Set boolean (persistent)

# Troubleshooting
ausearch -m avc            # Search for denials
audit2allow -a             # Generate policy from denials
semanage fcontext -l       # List file contexts
```

### 3. Monitoring and Logging
```bash
# Set up log monitoring
sudo tail -f /var/log/audit/audit.log | grep -i avc

# Install setroubleshoot for better error messages
sudo yum install setroubleshoot-server
sudo systemctl restart auditd
```

### 4. Backup and Recovery
```bash
# Create system backup before enabling SELinux
sudo tar -czf /root/selinux-backup-$(date +%Y%m%d).tar.gz \
    /etc/selinux/ /var/log/audit/

# Create rescue strategy
echo "selinux=0" >> /etc/default/grub.backup
```

---

## Common Issues and Solutions

### File Context Issues
```bash
# Problem: Files have incorrect contexts
# Solution: Restore contexts
sudo restorecon -R /

# Problem: Custom application contexts
# Solution: Create custom contexts
sudo semanage fcontext -a -t httpd_exec_t "/opt/myapp/bin(/.*)?"
sudo restorecon -R /opt/myapp/bin/
```

### Boolean Configuration
```bash
# Problem: Service denied by SELinux policy
# Solution: Check and set appropriate booleans
getsebool -a | grep httpd
sudo setsebool -P httpd_can_network_connect 1
```

### Port Labeling
```bash
# Problem: Service can't bind to non-standard port
# Solution: Label the port correctly
sudo semanage port -a -t http_port_t -p tcp 8080
```

---

## Quick Reference Commands

### Essential Commands Cheat Sheet
```bash
# Status Check
sestatus && getenforce

# Enable SELinux (persistent)
sudo sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
sudo touch /.autorelabel
sudo reboot

# Runtime mode switch
sudo setenforce 1  # Enable enforcing
sudo setenforce 0  # Switch to permissive

# Fix contexts
sudo restorecon -R /

# Check for denials
sudo ausearch -m avc -ts recent

# Common booleans
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P ssh_sysadm_login 1
```

---

## Testing Checklist

### Pre-Enablement Testing
- [ ] Create system backup
- [ ] Document current service status
- [ ] Test in non-production environment
- [ ] Prepare rollback procedure

### Post-Enablement Testing
- [ ] Verify `sestatus` shows "enforcing"
- [ ] Test SSH connectivity
- [ ] Verify web services (if applicable)
- [ ] Check application functionality
- [ ] Monitor audit logs for denials
- [ ] Test file access permissions

---

## Conclusion

Enabling SELinux in enforcing mode significantly enhances system security but requires careful planning and testing. Follow this guide step-by-step, always test in a non-production environment first, and be prepared to troubleshoot common issues.

Remember: **SELinux provides defense in depth** - it's an additional security layer that works alongside traditional file permissions and firewall rules.

For additional help:
- Red Hat SELinux Guide: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/
- SELinux Project: http://selinuxproject.org/
- Man pages: `man selinux`, `man sestatus`, `man setenforce`
