#!/bin/bash
HOSTNAME=$1
USER=$2
DISK=$3

##########
# REGION #
##########

# timezone
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

# locales
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

############
# PACKAGES #
############

echo "Installing packages..."
pacman -S --noconfirm \

	# Basic
	networkmanager ufw git vim sudo \

	# Drivers
	mesa xf86-video-amdgpu vulkan-radeon rocm-opencl-runtime \

	# Fonts
	noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
	
	# System
	fastfetch flatpak fuse

	read -p "Choose a DE (1-KDE 2-GNOME): " opcao
	case $opcao in
  1)
    echo "Installing GNOME..."
    pacman -S --noconfirm gnome kitty extension-manager
    systemctl enable gdm.service
    ;;
  2)
    echo "Installing KDE..."
    pacman -S --noconfirm plasma kitty dolphin ark
    systemctl enable plasmalogin.service
	sudo -u $USER dbus-launch kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
    ;;
  *)
    echo "Invalid Option!"
    exit 1
    ;;
	
########
# USER #
########

echo "Configuring user: $USER"
useradd -m -G wheel $USER
echo "$USER password:"
passwd $USER
echo $HOSTNAME > /etc/hostname

# Sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Services
systemctl enable NetworkManager.service
systemctl enable ufw.service

# Finish
rm /chroot_setup.sh
exit
