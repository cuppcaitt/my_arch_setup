#!/bin/bash
HOSTNAME=$1
USER=$2
DISK=$3

#        #
# REGION #
#        #
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#          #
# PACKAGES #
#          #
pacman -S \
	#
	# Basic
	networkmanager ufw git vim sudo \
	# 
	# Drivers
	mesa xf86-video-amdgpu vulkan-radeon rocm-opencl-runtime \
	#
	# System
	fastfetch plasma dolphin kitty ark flatpak fuse \
	#
	# Fonts
	noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \

#      #
# USER #
#      #
echo "Configurando usuário: $USER"
useradd -m -G wheel $USER
echo "Defina a senha para $USER:"
passwd $USER
echo $HOSTNAME > /etc/hostname

# Sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Default Terminal
sudo -u $USER dbus-launch kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty

# Services
systemctl enable NetworkManager.service
systemctl enable ufw.service
systemctl enable plasmalogin.service

# Finish
rm /chroot_setup.sh
exit
