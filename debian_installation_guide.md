# Debian Installation Guide - Step by Step

## 📖 Overview

This comprehensive guide provides step-by-step instructions for installing Debian using 131+ sequential screenshots. Each screenshot shows the exact installation screen and the selections you need to make.

## 🎯 Prerequisites

Before starting the installation, ensure you have:

- [ ] **Installation Media**: Debian ISO downloaded and burned to DVD/USB or loaded in VM
- [ ] **System Requirements**: Minimum 2GB RAM, 20GB disk space
- [ ] **Screenshots Extracted**: Run `tar -xf debinstall_all.tar` to extract all screenshots
- [ ] **Backup**: Important data backed up (for physical installations)

## 📸 How to Use This Guide

1. **Sequential Progression**: Follow screenshots in numerical order (debinstall_00100.png → debinstall_13400.png)
2. **Visual Reference**: Each screenshot shows the exact screen you should see
3. **Action Points**: Look for highlighted selections, text entries, or button clicks in each image
4. **Checkpoints**: Mark your progress using the checkboxes provided

---

## 🚀 Installation Phases

### Phase 1: Boot and Initial Setup (Screenshots 00100-00500)
**Screenshots**: `debinstall_00100.png` through `debinstall_00500.png`

**What you'll accomplish:**
- [ ] Boot from installation media
- [ ] Select installation method
- [ ] Choose language settings
- [ ] Configure basic system parameters

**Key Steps:**
- **Screenshot 00100**: Boot screen - Select "Install" or "Graphical Install"
- **Screenshot 00200**: Language selection
- **Screenshot 00300**: Location/country selection
- **Screenshot 00400**: Keyboard layout configuration
- **Screenshot 00500**: Network configuration begins

---

### Phase 2: Network and Hostname Configuration (Screenshots 00600-01500)
**Screenshots**: `debinstall_00600.png` through `debinstall_01500.png`

**What you'll accomplish:**
- [ ] Configure network interface
- [ ] Set hostname and domain name
- [ ] Configure network settings
- [ ] Establish internet connectivity

**Key Steps:**
- **Screenshots 00600-00800**: Network interface detection and configuration
- **Screenshots 00900-01100**: Hostname and domain configuration
- **Screenshots 01200-01500**: Network connectivity verification

---

### Phase 3: User and Password Setup (Screenshots 01600-03000)
**Screenshots**: `debinstall_01600.png` through `debinstall_03000.png`

**What you'll accomplish:**
- [ ] Set root password
- [ ] Create user account
- [ ] Configure user credentials
- [ ] Set up authentication

**Key Steps:**
- **Screenshots 01600-02000**: Root password configuration
- **Screenshots 02100-02500**: User account creation
- **Screenshots 02600-03000**: User password and details setup

---

### Phase 4: Disk Partitioning (Screenshots 03100-06000)
**Screenshots**: `debinstall_03100.png` through `debinstall_06000.png`

**What you'll accomplish:**
- [ ] Choose partitioning method
- [ ] Select target disk
- [ ] Configure partition layout
- [ ] Set up filesystems

**Key Steps:**
- **Screenshots 03100-03500**: Partitioning method selection (Guided vs Manual)
- **Screenshots 03600-04500**: Disk selection and partition scheme
- **Screenshots 04600-06000**: Filesystem configuration and partition finalization

**⚠️ Critical Phase**: Take extra care during partitioning to avoid data loss!

---

### Phase 5: Base System Installation (Screenshots 06100-08000)
**Screenshots**: `debinstall_06100.png` through `debinstall_08000.png`

**What you'll accomplish:**
- [ ] Install base system packages
- [ ] Configure package manager
- [ ] Set up core system components
- [ ] Install kernel and essential tools

**Key Steps:**
- **Screenshots 06100-06500**: Base system installation begins
- **Screenshots 06600-07500**: Package installation progress
- **Screenshots 07600-08000**: Base system configuration

---

### Phase 6: Package Manager and Mirror Configuration (Screenshots 08100-09500)
**Screenshots**: `debinstall_08100.png` through `debinstall_09500.png`

**What you'll accomplish:**
- [ ] Configure APT package manager
- [ ] Select Debian mirror
- [ ] Set up package repositories
- [ ] Configure proxy settings (if needed)

**Key Steps:**
- **Screenshots 08100-08500**: Package manager configuration
- **Screenshots 08600-09000**: Mirror selection and testing
- **Screenshots 09100-09500**: Repository setup completion

---

### Phase 7: Software Selection and Installation (Screenshots 09600-11500)
**Screenshots**: `debinstall_09600.png` through `debinstall_11500.png`

**What you'll accomplish:**
- [ ] Select software packages to install
- [ ] Choose desktop environment (if desired)
- [ ] Install additional software components
- [ ] Configure system services

**Key Steps:**
- **Screenshots 09600-10000**: Software selection menu (tasksel)
- **Screenshots 10100-10800**: Desktop environment selection
- **Screenshots 10900-11500**: Package installation progress

**Popular Selections:**
- **Desktop Environment**: GNOME, KDE, XFCE, or LXDE
- **Web Server**: Apache, Nginx
- **Development Tools**: Build essentials, version control
- **System Utilities**: Standard system tools

---

### Phase 8: Bootloader Installation (Screenshots 11600-12500)
**Screenshots**: `debinstall_11600.png` through `debinstall_12500.png`

**What you'll accomplish:**
- [ ] Install GRUB bootloader
- [ ] Configure boot options
- [ ] Set up multi-boot (if applicable)
- [ ] Finalize boot configuration

**Key Steps:**
- **Screenshots 11600-12000**: GRUB installation location selection
- **Screenshots 12100-12500**: Bootloader configuration and installation

---

### Phase 9: Installation Completion (Screenshots 12600-13400)
**Screenshots**: `debinstall_12600.png` through `debinstall_13400.png`

**What you'll accomplish:**
- [ ] Complete installation process
- [ ] Remove installation media
- [ ] Perform first boot
- [ ] Verify system functionality

**Key Steps:**
- **Screenshots 12600-12900**: Installation completion messages
- **Screenshots 13000-13200**: System reboot preparation
- **Screenshots 13300-13400**: First boot and login screen

---

## 📋 Installation Checklist

Use this checklist to track your progress:

### Pre-Installation
- [ ] Installation media prepared
- [ ] Screenshots extracted and accessible
- [ ] System requirements verified
- [ ] Important data backed up

### Installation Progress
- [ ] Phase 1: Boot and Initial Setup (00100-00500)
- [ ] Phase 2: Network Configuration (00600-01500)  
- [ ] Phase 3: User Setup (01600-03000)
- [ ] Phase 4: Disk Partitioning (03100-06000)
- [ ] Phase 5: Base System (06100-08000)
- [ ] Phase 6: Package Manager (08100-09500)
- [ ] Phase 7: Software Selection (09600-11500)
- [ ] Phase 8: Bootloader (11600-12500)
- [ ] Phase 9: Completion (12600-13400)

### Post-Installation
- [ ] System boots successfully
- [ ] User can log in
- [ ] Network connectivity works
- [ ] Installed software functions correctly
- [ ] System updates completed

---

## 🔍 Detailed Screenshot Navigation

### Quick Reference by Screenshot Number:

| Phase | Screenshot Range | Description |
|-------|------------------|-------------|
| Boot & Setup | 00100-00500 | Initial boot, language, keyboard |
| Network | 00600-01500 | Network configuration, hostname |
| Users | 01600-03000 | Root and user account setup |
| Partitioning | 03100-06000 | Disk partitioning and filesystems |
| Base System | 06100-08000 | Core system installation |
| Packages | 08100-09500 | Package manager and mirrors |
| Software | 09600-11500 | Software selection and installation |
| Bootloader | 11600-12500 | GRUB installation |
| Completion | 12600-13400 | Finishing and first boot |

---

## 💡 Tips for Success

### During Installation:
1. **Take Your Time**: Don't rush through the screenshots
2. **Double-Check**: Verify each selection before proceeding
3. **Screenshots First**: Always reference the screenshot before making selections
4. **Note Differences**: Your screens might look slightly different due to hardware/version differences

### For Partitioning (Critical Phase):
- **Backup First**: Always backup important data
- **Understand Options**: Read partition descriptions carefully
- **Default is Safe**: Use guided partitioning if unsure
- **Manual Advanced**: Only use manual partitioning if experienced

### Troubleshooting:
- **Screen Differences**: Minor variations are normal due to hardware differences
- **Missing Screenshots**: If a screenshot seems missing, continue to the next number
- **Stuck on Step**: Restart installation if severely stuck
- **Network Issues**: Verify cable connections and network settings

---

## 🛠 Common Customizations

### Minimal Installation:
- Skip desktop environment selection
- Choose only "Standard system utilities"
- Results in command-line only system

### Desktop Installation:
- Select desired desktop environment
- Include "Standard system utilities"
- Add "Laptop" if installing on laptop hardware

### Server Installation:
- Skip desktop environment
- Select "Web server" or "SSH server" as needed
- Include "Standard system utilities"

---

## 📞 Getting Help

If you encounter issues during installation:

1. **Reference Screenshots**: Ensure you're following the correct sequence
2. **Check Hardware**: Verify system meets minimum requirements
3. **Debian Documentation**: Consult official Debian installation guide
4. **Community Forums**: Debian user forums and mailing lists
5. **Start Over**: Sometimes a fresh installation is the quickest solution

---

## 🎓 Next Steps After Installation

Once installation is complete:

1. **System Updates**: Run `sudo apt update && sudo apt upgrade`
2. **Additional Software**: Install needed applications via APT
3. **Security**: Configure firewall and security settings
4. **Backup**: Set up regular backup procedures
5. **Documentation**: Keep notes of your configuration choices

---

**Happy Installing!** 🐧

*This guide covers Debian installation using 131+ step-by-step screenshots. Each screenshot provides visual confirmation of the installation progress and required selections.*
