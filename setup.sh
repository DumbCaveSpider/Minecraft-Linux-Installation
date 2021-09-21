#!/bin/bash

mkdir bin
chmod +x *
export MAIN_DIR=$PWD

######## General checks #########

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "> curl is required in order for this script to work."
  echo "> Install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

# firewall
CONFIGURE_FIREWALL=false
CONFIGURE_UFW=false
CONFIGURE_FIREWALL_CMD=false

# intro
echo "# Minecraft Linux Installation Script by DumbCaveSpider (ArcticWoof#6900) #"

# options
echo "> What would you like to setup? <"
echo "[1] Setup Minecraft Java"
echo "[2] Setup Minecraft Bedrock"
read -p "> Please enter a number: " choice

# no input
if [ -z $choice ] then
  echo "> Invaild Input! Please try again!"
  
elif [ $choice == "1" ] then
  echo "Installing MoreServerInfo..."
  
else
  echo "> Invaild Input! Please try again!"
fi 
