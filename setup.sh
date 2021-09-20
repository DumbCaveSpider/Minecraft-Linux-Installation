#!/bin/bash

set -e

######## General checks #########

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

# firewall
CONFIGURE_FIREWALL=false
CONFIGURE_UFW=false
CONFIGURE_FIREWALL_CMD=false

#################################
####### OS check funtions #######
#################################

detect_distro() {
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$(echo "$ID" | awk '{print tolower($0)}')
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

check_os_comp() {
  SUPPORTED=false

  MACHINE_TYPE=$(uname -m)
  case "$MACHINE_TYPE" in
  x86_64)
    ARCH=amd64
    ;;
  arm64) ;&
    # fallthrough
  aarch64)
    print_warning "Detected architecture arm64"
    print_warning "You will need to use Docker images made specifically for arm64"
    echo -e -n "* Are you sure you want to proceed? (y/N):"
    read -r choice

    if [[ ! "$choice" =~ [Yy] ]]; then
      print_error "Installation aborted!"
      exit 1
    fi
    ARCH=arm64
    ;;
  *)
    print_error "Only x86_64 and arm64 are supported for Wings"
    exit 1
    ;;
  esac

  case "$OS" in
  ubuntu)
    [ "$OS_VER_MAJOR" == "18" ] && SUPPORTED=true
    [ "$OS_VER_MAJOR" == "20" ] && SUPPORTED=true
    ;;
  debian)
    [ "$OS_VER_MAJOR" == "9" ] && SUPPORTED=true
    [ "$OS_VER_MAJOR" == "10" ] && SUPPORTED=true
    [ "$OS_VER_MAJOR" == "11" ] && SUPPORTED=true
    ;;
  centos)
    [ "$OS_VER_MAJOR" == "7" ] && SUPPORTED=true
    [ "$OS_VER_MAJOR" == "8" ] && SUPPORTED=true
    ;;
  *)
    SUPPORTED=false
    ;;
  esac

  # exit if not supported
  if [ "$SUPPORTED" == true ]; then
    echo "* $OS $OS_VER is supported."
  else
    echo "* $OS $OS_VER is not supported"
    print_error "Unsupported OS"
    exit 1
  fi

  # check virtualization
  echo -e "* Installing virt-what..."
  if [ "$OS" == "debian" ] || [ "$OS" == "ubuntu" ]; then
    # silence dpkg output
    export DEBIAN_FRONTEND=noninteractive

    # install virt-what
    apt-get -y update -qq
    apt-get install -y virt-what -qq

    # unsilence
    unset DEBIAN_FRONTEND
  elif [ "$OS" == "centos" ]; then
    if [ "$OS_VER_MAJOR" == "7" ]; then
      yum -q -y update

      # install virt-what
      yum -q -y install virt-what
    elif [ "$OS_VER_MAJOR" == "8" ]; then
      dnf -y -q update

      # install virt-what
      dnf install -y -q virt-what
    fi
  else
    print_error "Invalid OS."
    exit 1
  fi

  virt_serv=$(virt-what)

  case "$virt_serv" in
  *openvz* | *lxc*)
    print_warning "Unsupported type of virtualization detected. Please consult with your hosting provider whether your server can run Docker or not. Proceed at your own risk."
    echo -e -n "* Are you sure you want to proceed? (y/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Yy] ]]; then
      print_error "Installation aborted!"
      exit 1
    fi
    ;;
  *)
    [ "$virt_serv" != "" ] && print_warning "Virtualization: $virt_serv detected."
    ;;
  esac

  if uname -r | grep -q "xxxx"; then
    print_error "Unsupported kernel detected."
    exit 1
  fi
}

## Variables
output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

done=false

mkdir() {
  mkdir folder
}

## Intro
output "test"

## User Options
while [ "$done" == false ]; do
  options=(
    "test make directory"
  )
  
  actions=(
    "mkdir"
  )

  output "What would you like to do?"
# Read actions
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

done
