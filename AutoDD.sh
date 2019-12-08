#!/bin/sh

if [[ $EUID -ne 0 ]]; then
    clear
    echo "Error: This script must be run as root!" 1>&2
    exit 1
fi

function isValidIp() {
  local ip=$1
  local ret=1
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    ip=(${ip//\./ })
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    ret=$?
  fi
  return $ret
}

function updateIp() {
  CopyRight
  read -r -p "Your IP: " MAINIP
  read -r -p "Your Gateway: " GATEWAYIP
  read -r -p "Your Netmask: " NETMASK
}

function ipCheck() {
  isLegal=0
  for add in $MAINIP $GATEWAYIP $NETMASK; do
    isValidIp $add
    if [ $? -eq 1 ]; then
      isLegal=1
    fi
  done
  return $isLegal
}

function CopyRight() {
  clear
  echo "################################################"
  echo "#                                              #"
  echo "#  Auto ReInstall Script                       #"
  echo "#                                              #"
  echo "#  Author: hiCasper                            #"
  echo "#  Blog: https://blog.hicasper.com             #"
  echo "#  Last Modified: 2019-11-22                   #"
  echo "#                                              #"
  echo "#  Supported by MoeClub                        #"
  echo "#                                              #"
  echo "################################################"
  echo -e "\n"
}

function start() {
  CopyRight
  echo "IP: $MAINIP"
  echo "Gateway: $GATEWAYIP"
  echo "Netmask: $NETMASK"
  echo -e "\nPlease select an OS:"
  echo "  1) CentOS 7 (DD)"
  echo "  2) CentOS 6 (tuna mirror)"
  echo "  3) CentOS 6"
  echo "  4) Debian 9"
  echo "  5) Ubuntu 16.04"
  echo "  6) Ubuntu 18.04"
  echo "  7) Custom image"
  echo "  0) Exit"
  echo -ne "\nYour option: "
  read N
  case $N in
    1) echo "Password: Pwd@CentOS"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'https://api.moetools.net/get/centos-7-image' ;;
    2) bash /tmp/InstallNET.sh -c 6.9 -v 64 -a --mirror 'http://mirrors.tuna.tsinghua.edu.cn/centos-vault' --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $SUBNET ;;
    3) bash /tmp/InstallNET.sh -c 6.9 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK ;;
    4) bash /tmp/InstallNET.sh -d 9 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK ;;
    5) bash /tmp/InstallNET.sh -u 16.04 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK ;;
    6) bash /tmp/InstallNET.sh -u 18.04 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK ;;
    7)
      read -r -p "Custom image URL: " imgURL
      echo -e "\n"
      read -r -p "Are you sure start reinstall? [Y/n]: " input
      case $input in
        [yY][eE][sS]|[yY]) bash /tmp/InstallNET.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd $imgURL;;
        *) clear; echo "Canceled by user!"; exit 1;;
      esac
      ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
  esac
}

if [ -f "/tmp/InstallNET.sh" ]; then
  rm -f /tmp/InstallNET.sh
fi
wget --no-check-certificate -qO /tmp/InstallNET.sh 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh' && chmod a+x /tmp/InstallNET.sh

MAINIP=$(ip route get 1 | awk '{print $NF;exit}')
GATEWAYIP=$(ip route | grep default | awk '{print $3}')
SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')
value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"

ipCheck
if [ $? -eq 0 ]; then
  CopyRight
  echo "IP: $MAINIP"
  echo "Gateway: $GATEWAYIP"
  echo "Netmask: $NETMASK"
  echo -ne "\n"
  read -r -p "Please confirm your network infomation [Y/n]: " input
  case $input in
    [yY][eE][sS]|[yY]) start;;
    [nN][oO]|[nN])
      updateIp
      ipCheck
      if [ $? -eq 0 ]; then
        start
      else
        echo -e "\nIllegal address!"; exit 1
      fi
      ;;
    *) echo "Wrong input!"; exit 1;;
  esac
else
  echo -e "\nIllegal address!"
  updateIp
  ipCheck
  if [ $? -eq 0 ]; then
    start
  else
    echo -e "\nIllegal address!"
  fi
fi
