#!/bin/bash

#########################################################################################################################
#
# Script: install
#
# https://luchina.com.br
#
#########################################################################################################################

clear
# clear out old install.  Unfortunately, this also clears out the old logs if present
# so the setup script has been changed to log to /root/OSX-PROXMOX-LOGS
if [ -e /root/OSX-PROXMOX ]; then rm -rf /root/OSX-PROXMOX; fi;
# DISABLED removal of enterprise repository
# if [ -e /etc/apt/sources.list.d/pve-enterprise.list ]; then rm -rf /etc/apt/sources.list.d/pve-enterprise.list; fi;
# DISABLED removal of ceph repository
# if [ -e /etc/apt/sources.list.d/ceph.list ]; then rm -rf /etc/apt/sources.list.d/ceph.list; fi;
# The silent removal of these repositories hurt sesnsible customers paying for support.
# Is this better?
echo "Waiting to install OSX-PROXMOX..."
echo " "
INSLOG=/tmp/install-osx-proxmox.log
apt update >> ${INSLOG} 2>> ${INSLOG}

# if an error occurs, try to adjust the country specific repository to the root repository
# 
if [ $? -ne 0 ]
then 
	echo " "
	echo "Error with 'apt-get update' ..."
	echo "Trying to change /etc/apt/sources.list to not use the country specific debian mirror but the root mirror"
	echo " "
	# Always using a Brazilian server will not be fast...
 	# I suggest using the users home country, As it will always be faster.
 	Country=$(curl -s https://ipinfo.io/country | tr '[:upper:]' '[:lower:]')
  	echo "Changing source.list to point to root repository" >>${INSLOG}
	sed -i "s/ftp.$Country.debian.org/ftp.debian.org/g" /etc/apt/sources.list
		
	echo "Retrying 'apt-get update' ..."
	echo " "

	apt-get update >> ${INSLOG} 2>> ${INSLOG}
	
	if [ $? -ne 0 ]; then echo "Error with 'apt-get update' ..."; exit; fi		
fi
echo "Installing Git..."
apt install git -y >> ${INSLOG} 2>> ${INSLOG}
# changed to clone from the fork instead of the original
# original location: https://github.com/luchina-gabriel/OSX-PROXMOX.git
# fork location: https://github.com/luchina-gabriel/OSX-PROXMOX.git
git clone https://github.com/Lars-Berntrop-Bos-SKG/OSX-PROXMOX.git >> ${INSLOG} 2>> ${INSLOG}

if [ ! -e /root/OSX-PROXMOX ]; then mkdir -p /root/OSX-PROXMOX; fi;

/root/OSX-PROXMOX/setup
