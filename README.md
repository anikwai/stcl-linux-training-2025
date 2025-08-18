# STCL Linux Training 2025

Welcome to the STCL Linux Training program for 2025. This repository contains comprehensive training materials, guides, and exercises focused on Red Hat Enterprise Linux (RHEL) 10.

## 📋 Overview

This training program is designed to provide hands-on experience with Linux system administration, focusing on RHEL 10 installation, configuration, and management. Whether you're a beginner or looking to enhance your Linux skills, this training will guide you through essential concepts and practical implementations.

## 🎯 Learning Objectives

By the end of this training, participants will be able to:

- Install and configure RHEL 10 in a virtualized environment
- Understand Linux system architecture and core concepts
- Perform basic and advanced system administration tasks
- Configure network settings, security, and user management
- Work with package management systems (YUM/DNF)
- Implement security best practices including SELinux and firewall configuration

## 📚 Training Materials

### Current Content

- **[RHEL 10 Installation Guide](rhel10_installation.md)** - Comprehensive guide for setting up RHEL 10 in VirtualBox
- **[Debian Installation Screenshots](debinstall_all.tar)** - Complete visual guide with 131+ step-by-step screenshots for Debian installation
- **[Linux Foundation Course Outline](Linux%20Foundation%20-Course%20Outline.pdf)** - Official course curriculum and learning path from the Linux Foundation
- **[Advanced Linux Commands Cheat Sheet](advanced-linux-commands-cheat-sheet-red-hat-developer.pdf)** - Quick reference guide for advanced Linux commands from Red Hat Developer

### Upcoming Modules

- System Administration Basics
- User and Group Management
- File System Management
- Network Configuration
- Security Hardening
- Package Management
- Service Management with systemd
- Shell Scripting
- Log Management and Monitoring

## 🛠 Prerequisites

### Software Requirements

- **VirtualBox** - Download from [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- **VirtualBox Extension Pack** - [Download Extension Pack](https://download.virtualbox.org/virtualbox/7.2.0/Oracle_VirtualBox_Extension_Pack-7.2.0.vbox-extpack)
- **RHEL 10 ISO** - Available from [Red Hat Customer Portal](https://access.redhat.com/downloads/content/479/ver=/rhel---8/8.7/x86_64/product-software)

### Account Requirements

- **Red Hat Developer Account** - [Sign up here](https://developers.redhat.com/) for free access to RHEL

### System Requirements

- **RAM**: Minimum 8GB (16GB recommended for better performance)
- **Storage**: At least 50GB free space
- **CPU**: x86_64 processor with virtualization support (Intel VT-x or AMD-V)

## 🚀 Getting Started

1. **Clone or download this repository**
   ```bash
   git clone [repository-url]
   cd stcl-linux-training-2025
   ```

2. **Follow the installation guide**
   - Start with [rhel10_installation.md](rhel10_installation.md)
   - Complete each checklist item in order

3. **Set up your development environment**
   - Install VirtualBox and extension pack
   - Download RHEL 10 ISO
   - Create your Red Hat developer account

## 💿 Installation Instructions

### RHEL 10 Installation
For Red Hat Enterprise Linux installation, follow the comprehensive guide in [rhel10_installation.md](rhel10_installation.md) which includes:
- VirtualBox setup and configuration
- RHEL 10 ISO download and preparation
- Step-by-step VM creation
- Installation checklist and verification

### Debian Installation Screenshots
The repository includes a complete visual installation guide for Debian with 131+ step-by-step screenshots.

#### Accessing the Debian Installation Guide

1. **Extract the installation screenshots:**
   ```bash
   tar -xf debinstall_all.tar
   ```

2. **Organize screenshots by phase (recommended):**
   ```bash
   ./organize_screenshots.sh
   ```
   This creates a `debian_installation_phases/` directory with screenshots organized into 9 logical phases.

3. **Follow the organized guide:**
   - Navigate to `debian_installation_phases/Phase_1_Boot_and_Setup/` to begin
   - Each phase directory contains relevant screenshots and a README with instructions
   - Progress through phases sequentially for a structured installation experience

4. **Alternative - View all screenshots sequentially:**
   - Screenshots are numbered sequentially (debinstall_00100.png through debinstall_13400.png)
   - Start with `debinstall_00100.png` and progress through each numbered screenshot
   - Each screenshot shows the exact screen and selections needed

#### Installation Phases Covered:
1. **Boot and Initial Setup** (00100-00500) - Boot menu, language, keyboard
2. **Network Configuration** (00600-01500) - Network setup and hostname
3. **User and Password Setup** (01600-03000) - Account creation
4. **Disk Partitioning** (03100-06000) - Storage configuration ⚠️ Critical
5. **Base System Installation** (06100-08000) - Core system packages
6. **Package Manager Setup** (08100-09500) - APT and mirrors
7. **Software Selection** (09600-11500) - Desktop and applications
8. **Bootloader Installation** (11600-12500) - GRUB setup
9. **Installation Completion** (12600-13400) - Final steps and first boot

#### Using the Screenshots
- **Organized Method**: Use the phase-based structure for guided installation
- **Sequential Method**: Follow screenshots chronologically by filename
- Each image shows the current installation screen and any selections made
- Phase directories include README files with context and key actions
- Use as reference when installing Debian in VirtualBox or on physical hardware

## 📖 How to Use This Training

1. **Sequential Learning**: Follow the modules in order as each builds upon previous knowledge
2. **Hands-on Practice**: Each module includes practical exercises and labs
3. **Checkpoints**: Use the checklists to track your progress
4. **Documentation**: Take notes and document your configurations for reference

## 🎓 Training Structure

```
stcl-linux-training-2025/
├── README.md                                           # This file
├── rhel10_installation.md                             # RHEL 10 installation guide
├── debinstall_all.tar                                 # Debian installation screenshots archive
├── debinstall_*.png                                   # 131+ step-by-step Debian installation screenshots
├── Linux Foundation -Course Outline.pdf              # Official course curriculum
├── advanced-linux-commands-cheat-sheet-red-hat-developer.pdf  # Command reference
├── exercises/                                         # Hands-on exercises (coming soon)
├── scripts/                                           # Utility scripts (coming soon)
├── resources/                                         # Additional resources (coming soon)
└── labs/                                              # Lab assignments (coming soon)
```

## 📝 Progress Tracking

Track your progress using the checklists provided in each module. The current installation progress can be found in [rhel10_installation.md](rhel10_installation.md).

## 🤝 Contributing

This is a training repository. If you find errors or have suggestions for improvements, please:

1. Document the issue clearly
2. Provide steps to reproduce (if applicable)
3. Suggest corrections or improvements
4. Share your feedback with the training team

## 📞 Support

For technical support or questions about the training content:

- Review the documentation thoroughly first
- Check Red Hat documentation and community resources
- Consult with training instructors during scheduled sessions

## 🔗 Additional Resources

- [Red Hat Enterprise Linux Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/)
- [Red Hat Learning Subscription](https://www.redhat.com/en/services/training/learning-subscription)
- [Linux Command Line Basics](https://www.redhat.com/sysadmin/)
- [RHEL System Administrator's Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/system_administrators_guide/index)

## 📄 License

This training material is provided for educational purposes. Please respect Red Hat's licensing terms for RHEL software.

---

**Happy Learning!** 🐧

*Last updated: August 2025*
