#!/bin/bash

DISK="/dev/nvme0n1"
HOSTNAME="caitt-arch"
USER="cupcaitt"

##############
# PARTITIONS #
##############

# Partition Creation
echo "Adding partitions..."
sgdisk -Z $DISK
sgdisk -n 1:0:+1G -t 1:ef00 $DISK   # Boot (p1)
sgdisk -n 2:0:+8G -t 2:8200 $DISK   # Swap (p2)
sgdisk -n 3:0:0    -t 3:8300 $DISK   # Root (p3)

# Formating
echo "Formating..."
mkfs.fat -F32 "${DISK}p1"
mkswap "${DISK}p2"
mkfs.ext4 "${DISK}p3"

# Mounting
echo "Mounting..."
mount "${DISK}p3" /mnt
mkdir -p /mnt/boot
mount "${DISK}p1" /mnt/boot
swapon "${DISK}p2"

###############
# BASE SYSTEM #
###############

# System instalation
echo "Instaling system..."
pacstrap /mnt base base-devel linux linux-firmware amd-ucode

# Fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

################
# PART 2 SETUP #
################

# Enter chroot
echo "Starting chroot..."
cp chroot_setup.sh /mnt/
chmod +x /mnt/chroot_setup.sh
arch-chroot /mnt ./chroot_setup.sh $HOSTNAME $USER $DISK

#########################      
# BOOT (EFISTUB) CONFIG #
#########################

echo "Configuring boot..."
ROOT_UUID=$(blkid -s UUID -o value "${DISK}p3")

efibootmgr --create \
    --disk $DISK \
    --part 1 \
    --label "Arch Linux" \
    --loader /vmlinuz-linux \
    --unicode "root=UUID=$ROOT_UUID rw initrd=\amd-ucode.img initrd=\initramfs-linux.img"

echo "-------------------------"
echo "INSTALATION COMPLETED! :D"
echo "-------------------------"
