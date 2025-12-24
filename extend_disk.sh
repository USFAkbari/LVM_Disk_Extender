#!/bin/bash

# Title: VMware ESXi Ubuntu VM Disk Extension Script
# Description: Interactive script to extend root partition on Ubuntu VM in VMware ESXi
# Reference: https://www.ehostingserver.com/how-to-expand-root-partition-on-ubuntu-vm-in-vmware-esxi-a-step-by-step-guide/

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ubuntu VM Disk Extender for VMware ESXi ===${NC}"
echo "This script assumes you have already increased the disk size in ESXi settings."
echo ""

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root.${NC}" 
   exit 1
fi

# Step 0: Install dependencies
echo -e "${YELLOW}Step 0: Checking dependencies...${NC}"
if ! command -v growpart &> /dev/null; then
    echo "Installing cloud-guest-utils for growpart..."
    apt update && apt install -y cloud-guest-utils
else
    echo "cloud-guest-utils is already installed."
fi

# Step 1: Select Disk
echo -e "\n${YELLOW}Step 1: Select Disk to Rescan${NC}"
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -p "Enter disk name (default: sda): " DISK
DISK=${DISK:-sda}

if [ ! -e "/sys/class/block/$DISK/device/rescan" ]; then
    echo -e "${RED}Error: Device /dev/$DISK not found or does not support rescan.${NC}"
    exit 1
fi

# Step 2: Rescan Disk
echo -e "\n${YELLOW}Step 2: Rescanning /dev/$DISK...${NC}"
echo 1 > /sys/class/block/$DISK/device/rescan
echo "Rescan complete."
echo "Current disk map:"
lsblk /dev/$DISK

# Step 3: Select Partition
echo -e "\n${YELLOW}Step 3: Select Partition to Expand${NC}"
echo "Typically this is the LVM partition (e.g., partition 3 for sda3)."
read -p "Enter partition number to grow (default: 3): " PART_NUM
PART_NUM=${PART_NUM:-3}

# Step 4: Grow Partition
echo -e "\n${YELLOW}Step 4: Extending partition $PART_NUM on /dev/$DISK...${NC}"
growpart /dev/$DISK $PART_NUM
if [ $? -ne 0 ]; then
    echo -e "${RED}Warning: growpart returned an error. This might happen if the partition is already at max size. Continuing...${NC}"
fi

# Step 5: Detect and Resize Physical Volume (PV)
echo -e "\n${YELLOW}Step 5: Resizing Physical Volume (PV)...${NC}"
PART_PATH="/dev/${DISK}${PART_NUM}"
echo "Resizing PV on $PART_PATH..."
pvresize $PART_PATH

# Step 6: Select Logical Volume (LV)
echo -e "\n${YELLOW}Step 6: Select Logical Volume to Extend${NC}"
echo "Available Logical Volumes:"
lvs -o lv_name,vg_name,lv_path,lv_size
echo ""
read -p "Enter full LV Path to extend (default: /dev/ubuntu-vg/ubuntu-lv): " LV_PATH
LV_PATH=${LV_PATH:-/dev/ubuntu-vg/ubuntu-lv}

# Step 7: Extend Logical Volume
echo -e "\n${YELLOW}Step 7: Extending Logical Volume...${NC}"
lvextend -l +100%FREE $LV_PATH

# Step 8: Resize Filesystem
echo -e "\n${YELLOW}Step 8: Resizing Filesystem...${NC}"
# Detect filesystem type
FS_TYPE=$(df -TP $LV_PATH | tail -1 | awk '{print $2}')

if [[ "$FS_TYPE" == "ext4" ]]; then
    echo "Detected ext4 filesystem. Running resize2fs..."
    resize2fs $LV_PATH
elif [[ "$FS_TYPE" == "xfs" ]]; then
    echo "Detected xfs filesystem. Running xfs_growfs..."
    xfs_growfs $LV_PATH
else
    echo -e "${RED}Unknown or unsupported filesystem type: $FS_TYPE${NC}"
    echo "Please resize filesystem manually."
fi

# Verification
echo -e "\n${GREEN}=== Operation Complete ===${NC}"
echo "Updated Filesystem Space:"
df -h $LV_PATH
