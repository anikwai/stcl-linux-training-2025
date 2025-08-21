# RHEL Root Password Reset Guide

## Table of Contents
1. [Overview](#overview)
2. [RHEL 9.1 to 10.x Procedure](#rhel-91-to-10x-procedure)
3. [RHEL 7 to 9.0 Procedure](#rhel-7-to-90-procedure)
4. [Important Notes and Warnings](#important-notes-and-warnings)
5. [Troubleshooting](#troubleshooting)
6. [Security Considerations](#security-considerations)

---

## Overview

This guide provides detailed step-by-step procedures for resetting the root password on Red Hat Enterprise Linux (RHEL) systems when you have lost access. The process differs between RHEL versions due to changes in the boot process and systemd implementation.

### When to Use This Guide
- Lost or forgotten root password
- Need emergency access to a RHEL system
- System administration recovery scenarios
- Educational purposes for Linux system administrators

### Prerequisites
- Physical or console access to the RHEL system
- Basic understanding of Linux boot process
- Administrative authority to perform system recovery

---

## RHEL 9.1 to 10.x Procedure

### Method: Using init=/bin/bash

This method boots directly into a bash shell, bypassing the normal systemd initialization process.

#### Step 1: Initiate System Reboot
```bash
# If you have any access to the system, initiate a clean reboot
sudo reboot
```
**OR** perform a hard restart using physical power controls if necessary.

#### Step 2: Interrupt the Boot Process
1. **Watch the boot screen** for the GRUB boot loader
2. **Stop the countdown timer** by pressing the **Up** or **Down** arrow keys
3. The system will pause at the GRUB menu

#### Step 3: Edit the Boot Entry
1. **Select the kernel** to edit (usually the first entry in the list)
2. **Press the 'e' key** to enter edit mode
3. You will see the kernel boot parameters

#### Step 4: Modify Boot Parameters
1. **Locate the line** that begins with `linux`
2. **Remove** any `console` and/or `vconsole` directives from this line
   ```
   # Before (example):
   linux /vmlinuz-5.14.0 root=/dev/mapper/rhel-root console=tty0 vconsole.keymap=us
   
   # After:
   linux /vmlinuz-5.14.0 root=/dev/mapper/rhel-root
   ```
3. **Add `init=/bin/bash`** to the end of the line (ensure there's a space before it)
   ```
   # Final line should look like:
   linux /vmlinuz-5.14.0 root=/dev/mapper/rhel-root init=/bin/bash
   ```

#### Step 5: Boot with Modified Parameters
1. **Press Ctrl+X** to boot with the modified parameters
2. The system will boot directly into a bash shell

#### Step 6: Remount Root Filesystem as Read-Write
```bash
# At the bash-5.1# prompt, enter:
mount -o remount,rw /
```
**Purpose**: The root filesystem is initially mounted as read-only. This command makes it writable so you can modify the password file.

#### Step 7: Reset the Root Password
```bash
# Enter the passwd command
passwd

# You will be prompted to enter a new password twice:
New password: [enter your new password]
Retype new password: [confirm your new password]
```

#### Step 8: Create SELinux Relabel Flag
```bash
# CRITICAL: Run this command exactly as shown
touch /.autorelabel
```
**⚠️ WARNING**: Be extremely careful with this command. A typo could cause system damage.

**Purpose**: This creates a flag file that tells SELinux to relabel all files on the next boot, ensuring proper security contexts.

#### Step 9: Reboot the System
```bash
# Force an immediate reboot
/usr/sbin/reboot -f
```

#### Step 10: Complete the Process
1. **Wait for reboot** - The system may reboot multiple times during the SELinux relabeling process
2. **Be patient** - The first boot after relabeling can take several minutes
3. **Log in** with your new root password once the system is fully booted

---

## RHEL 7 to 9.0 Procedure

### Method: Using rd.break

This method interrupts the boot process at the initramfs stage, providing access to modify the system.

#### Step 1: Initiate System Reboot
```bash
# If you have any access to the system, initiate a clean reboot
sudo reboot
```
**OR** perform a hard restart using physical power controls if necessary.

#### Step 2: Interrupt the Boot Process
1. **Watch the boot screen** for the GRUB boot loader
2. **Stop the countdown timer** by pressing the **Up** or **Down** arrow keys
3. The system will pause at the GRUB menu

#### Step 3: Select and Edit Boot Entry
1. **Use arrow keys** to navigate and select the kernel to edit (usually the first entry)
2. **Press the 'e' key** to enter edit mode
3. You will see the kernel boot parameters

#### Step 4: Modify Boot Parameters
1. **Locate the line** that begins with `linux`
2. **Remove** any `console` and/or `vconsole` directives from this line
   ```
   # Before (example):
   linux16 /vmlinuz-3.10.0 root=/dev/mapper/rhel-root console=tty0 vconsole.keymap=us
   
   # After:
   linux16 /vmlinuz-3.10.0 root=/dev/mapper/rhel-root
   ```
3. **Add `rd.break`** to the end of the line (ensure there's a space before it)
   ```
   # Final line should look like:
   linux16 /vmlinuz-3.10.0 root=/dev/mapper/rhel-root rd.break
   ```

#### Step 5: Boot with Modified Parameters
1. **Press Ctrl+X** to boot with the modified parameters
2. The system will drop into an emergency shell at the initramfs stage

#### Step 6: Remount the System Root
```bash
# At the switch_root:/# prompt, run:
mount -o remount,rw /sysroot
```
**Purpose**: This mounts the actual system root filesystem in read-write mode under /sysroot.

#### Step 7: Change Root to System Root
```bash
# Change into the system root environment
chroot /sysroot
```
**Purpose**: This makes /sysroot the new root directory, giving you access to the full system environment.

#### Step 8: Reset the Root Password
```bash
# At the sh-4.4# prompt (version number may differ), enter:
passwd

# You will be prompted to enter a new password twice:
New password: [enter your new password]
Retype new password: [confirm your new password]
```

#### Step 9: Create SELinux Relabel Flag
```bash
# CRITICAL: Run this command exactly as shown
touch /.autorelabel
```
**⚠️ WARNING**: Be extremely careful with this command. A typo could cause system damage.

#### Step 10: Exit and Reboot
```bash
# Type 'exit' twice to return to normal boot process
exit
exit
```

#### Step 11: Complete the Process
1. **Wait for reboot** - The system may reboot multiple times during the SELinux relabeling process
2. **Be patient** - The first boot after relabeling can take several minutes
3. **Log in** with your new root password once the system is fully booted

---

## Important Notes and Warnings

### ⚠️ Critical Warnings

1. **Physical Access Required**: These procedures require physical or console access to the system
2. **SELinux Relabeling**: The `touch /.autorelabel` command is crucial - without it, you may not be able to log in
3. **Typo Prevention**: Be extremely careful when typing commands, especially the autorelabel command
4. **Multiple Reboots**: The system may reboot several times during the SELinux relabeling process
5. **Time Consumption**: The relabeling process can take a significant amount of time on large filesystems

### 🔍 Key Differences Between Versions

| Aspect | RHEL 7-9.0 | RHEL 9.1-10.x |
|--------|------------|---------------|
| **Boot Parameter** | `rd.break` | `init=/bin/bash` |
| **Initial Prompt** | `switch_root:/#` | `bash-5.1#` |
| **Root Remount** | `mount -o remount,rw /sysroot` | `mount -o remount,rw /` |
| **Chroot Required** | Yes (`chroot /sysroot`) | No |
| **Exit Method** | `exit` twice | `/usr/sbin/reboot -f` |

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Cannot Edit GRUB Menu
**Symptoms**: Unable to access GRUB edit mode
**Solutions**:
- Try pressing 'e' multiple times during boot
- Ensure you're stopping the countdown timer first
- Check if system has UEFI Secure Boot enabled (may require different approach)

#### Issue: SELinux Relabeling Takes Too Long
**Symptoms**: System appears to hang during boot after password reset
**Solutions**:
- Be patient - relabeling can take 30+ minutes on large systems
- If system truly hangs, boot with `selinux=0` temporarily and run `fixfiles relabel` manually

#### Issue: "Authentication token manipulation error"
**Symptoms**: Password change fails
**Solutions**:
- Ensure root filesystem is mounted read-write
- Check disk space availability
- Verify /etc directory permissions

#### Issue: System Boots to Emergency Mode
**Symptoms**: After following procedure, system boots to emergency shell
**Solutions**:
- Check `/var/log/messages` for clues
- Verify filesystem integrity with `fsck`
- Ensure proper SELinux contexts with `restorecon -R /`

---

## Security Considerations

### 🔒 Security Implications

1. **Physical Security**: These procedures highlight the importance of physical security
2. **Boot Security**: Consider implementing GRUB password protection
3. **Audit Trail**: Password resets may not be logged in standard audit logs
4. **Policy Compliance**: Ensure this procedure aligns with organizational security policies

### 🛡️ Preventive Measures

1. **Multiple Admin Accounts**: Maintain multiple administrative accounts
2. **SSH Key Authentication**: Use SSH keys instead of passwords where possible
3. **Centralized Authentication**: Implement LDAP/Active Directory integration
4. **Documentation**: Maintain secure documentation of emergency procedures
5. **Regular Testing**: Test recovery procedures in development environments

### 📝 Post-Recovery Actions

1. **Change Password Again**: Consider changing the password again from a normal session
2. **Review Logs**: Check system logs for any issues during the recovery process
3. **Update Documentation**: Document when and why the recovery was performed
4. **Security Review**: Review why the password was lost and implement preventive measures

---

## Summary

This guide provides comprehensive procedures for recovering root access on RHEL systems. The key difference between RHEL versions is the boot interruption method:

- **RHEL 9.1+**: Use `init=/bin/bash` for direct shell access
- **RHEL 7-9.0**: Use `rd.break` for initramfs interruption

Remember that both procedures require the critical `touch /.autorelabel` step to ensure proper SELinux operation after password reset.

### Quick Reference Commands

**RHEL 9.1+**:
```bash
# Boot parameter: init=/bin/bash
mount -o remount,rw /
passwd
touch /.autorelabel
/usr/sbin/reboot -f
```

**RHEL 7-9.0**:
```bash
# Boot parameter: rd.break
mount -o remount,rw /sysroot
chroot /sysroot
passwd
touch /.autorelabel
exit
exit
```

---

*This guide is intended for authorized system administrators only. Always follow your organization's security policies and procedures when performing system recovery operations.*
