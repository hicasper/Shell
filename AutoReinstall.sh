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
  echo "########################################################"
  echo "#                                                      #"
  echo "#  Auto Reinstall Script                               #"
  echo "#                                                      #"
  echo "#  Author: hiCasper                                    #"
  echo "#  Blog: blog.hicasper.com/post/135.html               #"
  echo "#  Feedback: https://github.com/hiCasper/Shell/issues  #"
  echo "#  Last Modified: 2020-02-18                           #"
  echo "#                                                      #"
  echo "#  Supported by MoeClub                                #"
  echo "#                                                      #"
  echo "########################################################"
  echo -e "\n"
}

function start() {
  CopyRight
  echo "IP: $MAINIP"
  echo "Gateway: $GATEWAYIP"
  echo "Netmask: $NETMASK"
  echo -e "\nPlease select an OS:"
  echo "  1) CentOS 7.7 (DD Image)"
  echo "  2) CentOS 7.6 (ServerSpeeder Avaliable)"
  echo "  3) CentOS 6"
  echo "  4) Debian 9"
  echo "  5) Debian 10"
  echo "  6) Ubuntu 16.04"
  echo "  7) Ubuntu 18.04"
  echo "  8) Custom image"
  echo "  0) Exit"
  echo -ne "\nYour option: "
  read N
  case $N in
    1) echo -e "\nPassword: Pwd@CentOS\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'https://api.moetools.net/get/centos-7-image' $DMIRROR ;;
    2) echo -e "\nPassword: Pwd@CentOS\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'https://api.moetools.net/get/centos-76-image' $DMIRROR ;;
    3) echo -e "\nPassword: Pwd@Linux\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh -c 6.10 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $CMIRROR ;;
    4) echo -e "\nPassword: Pwd@Linux\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh -d 9 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $DMIRROR ;;
    5) echo -e "\nPassword: Pwd@Linux\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh -d 10 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $DMIRROR ;;
    6) echo -e "\nPassword: Pwd@Linux\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh -u 16.04 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $UMIRROR ;;
    7) echo -e "\nPassword: Pwd@Linux\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh -u 18.04 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $UMIRROR ;;
    8)
      echo -e "\n"
      read -r -p "Custom image URL: " imgURL
      echo -e "\n"
      read -r -p "Are you sure start reinstall? [Y/n]: " input
      case $input in
        [yY][eE][sS]|[yY]) bash /tmp/InstallNET.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd $imgURL $DMIRROR ;;
        *) clear; echo "Canceled by user!"; exit 1;;
      esac
      ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
  esac
}

CMIRROR=''
CVMIRROR=''
DMIRROR=''
UMIRROR=''
isCN='0'

geoip=$(wget --no-check-certificate -qO- https://api.ip.sb/geoip | grep "\"country_code\":\"CN\"")
if [[ "$geoip" != "" ]];then
  isCN='1'
fi

if [ -f "/tmp/InstallNET.sh" ]; then
  rm -f /tmp/InstallNET.sh
fi
wget --no-check-certificate -qO /tmp/InstallNET.sh 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh' && chmod a+x /tmp/InstallNET.sh

if [[ "$isCN" == '1' ]];then
  sed -i 's#https://moeclub.org/get/wget_udeb_amd64#https://api.moetools.net/get/wget_udeb_amd64#' /tmp/InstallNET.sh
  CMIRROR="--mirror http://mirrors.aliyun.com/centos/"
  CVMIRROR="--mirror http://mirrors.tuna.tsinghua.edu.cn/centos-vault/"
  DMIRROR="--mirror http://mirrors.aliyun.com/debian/"
  UMIRROR="--mirror http://mirrors.aliyun.com/ubuntu/"
fi

sed -i 's/$1$4BJZaD0A$y1QykUnJ6mXprENfwpseH0/$1$7R4IuxQb$J8gcq7u9K0fNSsDNFEfr90/' /tmp/InstallNET.sh
sed -i '/force-efi-extra-removable/d' /tmp/InstallNET.sh

MAINIP=$(ip route get 1 | awk -F 'src ' '{print $2}' | awk '{print $1}')
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
  if [[ "$isCN" == '1' ]];then
    echo "Using domestic mode."
  fi
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
