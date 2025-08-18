#!/bin/bash

# Debian Installation Screenshot Organization Script
# This script organizes the 131+ screenshots into logical phases for easier navigation

echo "🔧 Organizing Debian Installation Screenshots..."

# Create phase directories
mkdir -p "debian_installation_phases"
cd "debian_installation_phases"

# Phase 1: Boot and Initial Setup (00100-00500)
mkdir -p "Phase_1_Boot_and_Setup"
echo "📁 Creating Phase 1: Boot and Initial Setup"
cp ../debinstall_0010*.png "Phase_1_Boot_and_Setup/" 2>/dev/null || true
cp ../debinstall_0020*.png "Phase_1_Boot_and_Setup/" 2>/dev/null || true
cp ../debinstall_0030*.png "Phase_1_Boot_and_Setup/" 2>/dev/null || true
cp ../debinstall_0040*.png "Phase_1_Boot_and_Setup/" 2>/dev/null || true
cp ../debinstall_0050*.png "Phase_1_Boot_and_Setup/" 2>/dev/null || true

# Phase 2: Network Configuration (00600-01500)
mkdir -p "Phase_2_Network_Config"
echo "📁 Creating Phase 2: Network Configuration"
for i in {600..1500..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_2_Network_Config/" 2>/dev/null || true
    # Also copy intermediate screenshots
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 1500 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_2_Network_Config/" 2>/dev/null || true
        fi
    done
done

# Phase 3: User Setup (01600-03000)
mkdir -p "Phase_3_User_Setup"
echo "📁 Creating Phase 3: User and Password Setup"
for i in {1600..3000..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_3_User_Setup/" 2>/dev/null || true
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 3000 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_3_User_Setup/" 2>/dev/null || true
        fi
    done
done

# Phase 4: Disk Partitioning (03100-06000)
mkdir -p "Phase_4_Partitioning"
echo "📁 Creating Phase 4: Disk Partitioning"
for i in {3100..6000..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_4_Partitioning/" 2>/dev/null || true
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 6000 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_4_Partitioning/" 2>/dev/null || true
        fi
    done
done

# Phase 5: Base System (06100-08000)
mkdir -p "Phase_5_Base_System"
echo "📁 Creating Phase 5: Base System Installation"
for i in {6100..8000..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_5_Base_System/" 2>/dev/null || true
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 8000 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_5_Base_System/" 2>/dev/null || true
        fi
    done
done

# Phase 6: Package Manager (08100-09500)
mkdir -p "Phase_6_Package_Manager"
echo "📁 Creating Phase 6: Package Manager Configuration"
for i in {8100..9500..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_6_Package_Manager/" 2>/dev/null || true
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 9500 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_6_Package_Manager/" 2>/dev/null || true
        fi
    done
done

# Phase 7: Software Selection (09600-11500)
mkdir -p "Phase_7_Software_Selection"
echo "📁 Creating Phase 7: Software Selection"
for i in {9600..11500..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_7_Software_Selection/" 2>/dev/null || true
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 11500 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_7_Software_Selection/" 2>/dev/null || true
        fi
    done
done

# Phase 8: Bootloader (11600-12500)
mkdir -p "Phase_8_Bootloader"
echo "📁 Creating Phase 8: Bootloader Installation"
for i in {11600..12500..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_8_Bootloader/" 2>/dev/null || true
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 12500 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_8_Bootloader/" 2>/dev/null || true
        fi
    done
done

# Phase 9: Completion (12600-13400)
mkdir -p "Phase_9_Completion"
echo "📁 Creating Phase 9: Installation Completion"
for i in {12600..13400..100}; do
    cp ../debinstall_$(printf "%05d" $i).png "Phase_9_Completion/" 2>/dev/null || true
    for j in {0..99}; do
        num=$((i + j))
        if [ $num -le 13400 ]; then
            cp ../debinstall_$(printf "%05d" $num).png "Phase_9_Completion/" 2>/dev/null || true
        fi
    done
done

# Create README files for each phase
cd ..

# Generate phase-specific README files
cat > "debian_installation_phases/Phase_1_Boot_and_Setup/README.md" << 'EOF'
# Phase 1: Boot and Initial Setup

## Screenshots: 00100-00500

This phase covers:
- Booting from installation media
- Selecting installation method (Install vs Graphical Install)
- Language selection
- Location/country configuration
- Keyboard layout setup
- Initial network detection

## Key Actions:
1. Select "Install" or "Graphical Install" from boot menu
2. Choose your preferred language
3. Select your country/region
4. Configure keyboard layout
5. Allow network auto-detection to begin

**Next Phase**: Network Configuration
EOF

cat > "debian_installation_phases/Phase_2_Network_Config/README.md" << 'EOF'
# Phase 2: Network and Hostname Configuration

## Screenshots: 00600-01500

This phase covers:
- Network interface configuration
- Hostname setup
- Domain name configuration
- Network connectivity establishment

## Key Actions:
1. Configure network interface (usually automatic)
2. Set system hostname
3. Configure domain name (can be left blank for home use)
4. Verify network connectivity

**Next Phase**: User and Password Setup
EOF

cat > "debian_installation_phases/Phase_3_User_Setup/README.md" << 'EOF'
# Phase 3: User and Password Setup

## Screenshots: 01600-03000

This phase covers:
- Root password configuration
- User account creation
- User password setup
- Account verification

## Key Actions:
1. Set a strong root password
2. Create a regular user account
3. Set user password
4. Verify account details

**Security Note**: Use strong passwords for both root and user accounts.

**Next Phase**: Disk Partitioning
EOF

cat > "debian_installation_phases/Phase_4_Partitioning/README.md" << 'EOF'
# Phase 4: Disk Partitioning

## Screenshots: 03100-06000

⚠️ **CRITICAL PHASE** - Take extra care to avoid data loss!

This phase covers:
- Partitioning method selection
- Disk selection
- Partition layout configuration
- Filesystem setup

## Key Actions:
1. Choose partitioning method (Guided recommended for beginners)
2. Select target disk
3. Configure partition scheme
4. Set up filesystems
5. Confirm partitioning changes

**Backup Warning**: Ensure important data is backed up before proceeding.

**Next Phase**: Base System Installation
EOF

cat > "debian_installation_phases/Phase_5_Base_System/README.md" << 'EOF'
# Phase 5: Base System Installation

## Screenshots: 06100-08000

This phase covers:
- Installing core Debian packages
- Setting up base system components
- Kernel installation
- Essential tool setup

## Key Actions:
1. Monitor base system installation progress
2. Allow core packages to install
3. Wait for kernel and essential tools setup
4. Verify base system completion

**Note**: This phase may take some time depending on system speed.

**Next Phase**: Package Manager Configuration
EOF

cat > "debian_installation_phases/Phase_6_Package_Manager/README.md" << 'EOF'
# Phase 6: Package Manager and Mirror Configuration

## Screenshots: 08100-09500

This phase covers:
- APT package manager setup
- Debian mirror selection
- Repository configuration
- Proxy settings (if needed)

## Key Actions:
1. Configure APT package manager
2. Select closest/fastest Debian mirror
3. Test mirror connectivity
4. Set up package repositories
5. Configure proxy if required

**Next Phase**: Software Selection
EOF

cat > "debian_installation_phases/Phase_7_Software_Selection/README.md" << 'EOF'
# Phase 7: Software Selection and Installation

## Screenshots: 09600-11500

This phase covers:
- Software package selection (tasksel)
- Desktop environment choice
- Additional component installation
- System service configuration

## Key Actions:
1. Use tasksel to choose software packages
2. Select desktop environment (GNOME, KDE, XFCE, etc.)
3. Choose additional components (web server, development tools)
4. Monitor installation progress

**Popular Choices**:
- Desktop users: Select a desktop environment
- Server users: Skip desktop, select server components
- Developers: Include development tools

**Next Phase**: Bootloader Installation
EOF

cat > "debian_installation_phases/Phase_8_Bootloader/README.md" << 'EOF'
# Phase 8: Bootloader Installation

## Screenshots: 11600-12500

This phase covers:
- GRUB bootloader installation
- Boot configuration
- Multi-boot setup (if applicable)
- Boot options finalization

## Key Actions:
1. Install GRUB bootloader to main disk
2. Configure boot options
3. Set up multi-boot if multiple operating systems present
4. Finalize bootloader configuration

**Next Phase**: Installation Completion
EOF

cat > "debian_installation_phases/Phase_9_Completion/README.md" << 'EOF'
# Phase 9: Installation Completion

## Screenshots: 12600-13400

This phase covers:
- Installation process completion
- System reboot preparation
- First boot sequence
- Login verification

## Key Actions:
1. Complete installation process
2. Remove installation media when prompted
3. Reboot system
4. Verify successful first boot
5. Test user login

**Congratulations!** Your Debian installation is complete.

## Next Steps:
1. Run system updates: `sudo apt update && sudo apt upgrade`
2. Install additional software as needed
3. Configure system settings
4. Set up backups
EOF

# Create main organization summary
cat > "debian_installation_phases/README.md" << 'EOF'
# Debian Installation Screenshots - Organized by Phase

This directory contains the 131+ Debian installation screenshots organized into logical phases for easier navigation.

## Phase Structure:

1. **Phase_1_Boot_and_Setup** (00100-00500) - Initial boot and basic setup
2. **Phase_2_Network_Config** (00600-01500) - Network and hostname configuration  
3. **Phase_3_User_Setup** (01600-03000) - User accounts and passwords
4. **Phase_4_Partitioning** (03100-06000) - Disk partitioning ⚠️ Critical phase
5. **Phase_5_Base_System** (06100-08000) - Base system installation
6. **Phase_6_Package_Manager** (08100-09500) - APT and mirror configuration
7. **Phase_7_Software_Selection** (09600-11500) - Software and desktop selection
8. **Phase_8_Bootloader** (11600-12500) - GRUB bootloader installation
9. **Phase_9_Completion** (12600-13400) - Completion and first boot

Each phase directory contains:
- Relevant screenshots for that installation phase
- README.md with phase-specific instructions
- Clear progression from one phase to the next

## Usage:
1. Navigate to Phase_1_Boot_and_Setup to begin
2. Follow screenshots in numerical order within each phase
3. Read the phase README for context and key actions
4. Progress through phases sequentially

## Tips:
- Each screenshot shows the exact screen you should see
- Take your time, especially during partitioning (Phase 4)
- Screenshots are numbered chronologically
- Refer to the main installation guide for detailed instructions
EOF

echo ""
echo "✅ Screenshot organization complete!"
echo ""
echo "📂 Created organized structure in: debian_installation_phases/"
echo ""
echo "📋 Phase Summary:"
echo "  Phase 1: Boot and Setup ($(ls debian_installation_phases/Phase_1_Boot_and_Setup/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 2: Network Config ($(ls debian_installation_phases/Phase_2_Network_Config/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 3: User Setup ($(ls debian_installation_phases/Phase_3_User_Setup/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 4: Partitioning ($(ls debian_installation_phases/Phase_4_Partitioning/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 5: Base System ($(ls debian_installation_phases/Phase_5_Base_System/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 6: Package Manager ($(ls debian_installation_phases/Phase_6_Package_Manager/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 7: Software Selection ($(ls debian_installation_phases/Phase_7_Software_Selection/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 8: Bootloader ($(ls debian_installation_phases/Phase_8_Bootloader/*.png 2>/dev/null | wc -l) screenshots)"
echo "  Phase 9: Completion ($(ls debian_installation_phases/Phase_9_Completion/*.png 2>/dev/null | wc -l) screenshots)"
echo ""
echo "🚀 Ready to begin installation! Start with debian_installation_phases/Phase_1_Boot_and_Setup/"
