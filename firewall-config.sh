#!/bin/bash
ROUTER_IP=192.168.1.1
LAN_SUBNET=$ROUTER_IP/24

# disable ufw first so we don't get locked out
ufw disable
# lock down all ports by default
ufw default deny
# allow WAN connections to containerized nginx reverse proxy
ufw allow to 443
# allow LAN connections for SSH
ufw allow from $LAN_SUBNET to any port 22
# allow LAN connections for Samba
ufw allow from $LAN_SUBNET to any port 139
ufw allow from $LAN_SUBNET to any port 445
# enable UFW
ufw enable
