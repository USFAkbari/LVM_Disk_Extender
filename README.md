```
  _____  _     _      ______      _                 _           
 |  __ \(_)   | |    |  ____|    | |               | |          
 | |  | |_ ___| | __ | |__  __  _| |_ ___ _ __   __| | ___ _ __ 
 | |  | | / __| |/ / |  __| \ \/ / __/ _ \ '_ \ / _` |/ _ \ '__|
 | |__| | \__ \   <  | |____ >  <| ||  __/ | | | (_| |  __/ |   
 |_____/|_|___/_|\_\ |______/_/\_\\__\___|_| |_|\__,_|\___|_|   
                                                                
```

<div align="center">

[![GitHub forks](https://img.shields.io/github/forks/USFAkbari/LVM_Disk_Extender?style=flat-square&logo=github&color=blue)](https://github.com/USFAkbari/LVM_Disk_Extender/network)
[![GitHub stars](https://img.shields.io/github/stars/USFAkbari/LVM_Disk_Extender?style=flat-square&logo=github&color=yellow)](https://github.com/USFAkbari/LVM_Disk_Extender/stargazers)
[![License](https://img.shields.io/github/license/USFAkbari/LVM_Disk_Extender?style=flat-square&color=orange)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/USFAkbari/LVM_Disk_Extender?style=flat-square&logo=github&color=purple)](https://github.com/USFAkbari/LVM_Disk_Extender/issues)

</div>

# VMware ESXi Ubuntu VM Disk Extender

A robust, interactive Bash script designed to simplify the process of extending the root partition (LVM) on Ubuntu Virtual Machines hosted on VMware ESXi.

## 🚀 Overview

Extending a Linux disk in a VMware environment usually involves a series of manual commands: rescanning the SCSI bus, resizing the partition, resizing the physical volume (PV), extending the logical volume (LV), and finally resizing the filesystem. 

This script automates the orchestration of these steps into a guided, interactive wizard, reducing the risk of error and saving time.

## ✨ Features

- **Interactive Wizard**: Step-by-step prompts guide you through the process.
- **Dependency Management**: Automatically checks for and installs `cloud-guest-utils` (required for `growpart`).
- **Safety First**: Validates root privileges and checks for device existence.
- **Auto-Detection**: 
  - Detects filesystem types (`ext4`, `xfs`) and applies the correct resize command.
  - Lists available disks and partitions to help you choose the correct target.
- **LVM Support**: specifically designed for LVM (Logical Volume Manager) setups.

## 📋 Prerequisites

- **VMware ESXi**: You must have already increased the allocated disk size for the VM in the ESXi/vCenter settings.
- **OS**: Ubuntu (or Debian-based distros using LVM).
- **Permissions**: Root access (sudo).

## 🛠️ Usage

### Quick Install (One-liner)

Download and execute the script directly:
```bash
curl -fsSL https://raw.githubusercontent.com/USFAkbari/LVM_Disk_Extender/main/extend_disk.sh | sudo bash
```

### Manual Installation

1. **Clone the repository** (or download the script):
   ```bash
   git clone https://github.com/USFAkbari/LVM_Disk_Extender.git
   cd LVM_Disk_Extender
   ```

2. **Make the script executable**:
   ```bash
   chmod +x extend_disk.sh
   ```

3. **Run the script**:
   ```bash
   sudo ./extend_disk.sh
   ```

4. **Follow the verification steps**:
   - **Step 1**: Select the disk to rescan (usually `sda`).
   - **Step 2**: The script rescans the disk to detect the new unallocated space.
   - **Step 3**: Select the partition to expand (usually the last one, e.g., `3`).
   - **Step 4**: The partition is grown.
   - **Step 5**: The Physical Volume (PV) is resized.
   - **Step 6**: Select the Logical Volume (LV) to extend (defaults to `/dev/ubuntu-vg/ubuntu-lv`).
   - **Step 7**: The LV is extended to use 100% of the free space.
   - **Step 8**: The filesystem is resized on the fly.

## ⚠️ Disclaimer

**ALWAYS BACK UP YOUR DATA BEFORE MODIFYING DISK PARTITIONS.**

While this script has been tested and includes safety checks, manipulating disk partitions and filesystems carries inherent risks. The author is not responsible for any data loss that may occur. Please ensure you have a valid snapshot or backup of your VM before proceeding.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
