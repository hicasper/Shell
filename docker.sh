#!/bin/bash

[[ "$EUID" -ne '0' ]] && echo "Error:This script must be run as root!" && exit 1;
if [[ -f "/usr/bin/yum" && -f "/etc/selinux/config" ]]; then
  setenforce 0
  sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
fi

while [ $# -gt 0 ]; do
  case $1 in
    uninstall)
      UNINST=1
      ;;
    -v|--version)
      VER=$2
      shift
      ;;
    *)
      echo "Unknown option: \"$1\""
      exit
  esac
  shift
done

if [ "$UNINST" == '1' ]; then
  if [ -f "/usr/bin/apt-get" ]; then
  apt-get remove docker docker-engine docker.io containerd runc
  fi
  if [ -f "/usr/bin/yum" ]; then
  yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
  fi
  echo Uninstall done!
  exit
fi

COUNTRY=$(curl -fsSL http://ipinfo.io | grep -o '"country": "[^"]*' | grep -o '[^"]*$')

REPO='https://download.docker.com'
if [ "$COUNTRY" == 'CN' ]; then
  REPO='https://mirrors.aliyun.com/docker-ce'
fi

if [ -f "/usr/bin/apt-get" ]; then
  isDebian=$(cat /etc/issue | grep Debian)
  apt-get remove docker docker-engine docker.io containerd runc
  apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
  if [ -z "$isDebian" ]; then
    curl -fsSL $REPO/linux/debian/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] $REPO/linux/debian $(lsb_release -cs) stable"
  else
    curl -fsSL $REPO/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] $REPO/linux/ubuntu $(lsb_release -cs) stable"
  fi
  apt-get install docker-ce
fi

case "$VER" in
  "1809") RPMS='docker-ce-18.09.9 docker-ce-cli-18.09.9 containerd.io-1.2.13' ;;
  "1903") RPMS='docker-ce-19.03.15 docker-ce-cli-19.03.15 containerd.io-1.3.9' ;;
  "2010") RPMS='docker-ce-20.10.17 docker-ce-cli-20.10.17 docker-ce-rootless-extras-20.10.17 containerd.io-1.6.8 docker-compose-plugin-2.6.0' ;;
  *) RPMS='docker-ce docker-ce-cli containerd.io docker-compose-plugin' ;;
esac

if [ -f "/usr/bin/yum" ]; then
  yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
  yum install -y yum-utils
  if [ "$VER" == "1809" ] || [ "$VER" == "1903" ] ; then
    yum install -y device-mapper-persistent-data
  fi
  yum-config-manager --add-repo $REPO/linux/centos/docker-ce.repo
  yum install -y $RPMS
fi

systemctl start docker
cat > /etc/docker/daemon.json <<EOF
{
  "live-restore": true,
  "log-level": "warn",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "32m",
    "max-file": "1"
  }
}
EOF

if [[ -f "/usr/bin/yum" && -f "/etc/selinux/config" ]]; then
  sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
fi

systemctl restart docker
systemctl enable docker

echo "Done!"
