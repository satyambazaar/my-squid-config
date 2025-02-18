#!/bin/bash

############################################################
# Squid Proxy Installer (Customized)
# Author: ServerOk (Modified)
# Description: Installs Squid Proxy with custom settings
############################################################

if [ `whoami` != root ]; then
    echo "ERROR: Run as root or use sudo."
    exit 1
fi

# Install required packages
/usr/bin/apt update > /dev/null 2>&1
/usr/bin/apt -y install apache2-utils squid > /dev/null 2>&1

# Configure Squid
touch /etc/squid/passwd
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
/usr/bin/touch /etc/squid/blacklist.acl

# Download custom Squid config
/usr/bin/wget -q --no-check-certificate -O /etc/squid/squid.conf https://raw.githubusercontent.com/serverok/squid-proxy-installer/master/conf/ubuntu-2204.conf

# Modify Squid Config to use port 5515
sed -i 's/http_port 3128/http_port 5515/' /etc/squid/squid.conf

# Set up authentication for user 'sunny' with password 'Puja1'
echo "sunny:$(openssl passwd -crypt Puja1)" | tee -a /etc/squid/passwd > /dev/null

# Allow Squid port in firewall
if [ -f /sbin/iptables ]; then
    /sbin/iptables -I INPUT -p tcp --dport 5515 -j ACCEPT
    /sbin/iptables-save
fi

# Restart and enable Squid service
systemctl enable squid > /dev/null 2>&1
systemctl restart squid

GREEN='\033[0;32m'
NC='\033[0m'
CYAN='\033[0;36m'

echo -e "${NC}"
echo -e "${GREEN}Squid Proxy Installed with Port 5515.${NC}"
echo -e "${CYAN}Username: sunny${NC}"
echo -e "${CYAN}Password: Puja1${NC}"
echo -e "${CYAN}To edit config, use: sudo nano /etc/squid/squid.conf${NC}"
