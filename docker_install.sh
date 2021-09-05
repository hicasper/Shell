#!/bin/bash

[[ "$EUID" -ne '0' ]] && echo "Error:This script must be run as root!" && exit 1;

isCN='0'
geoip=$(wget --no-check-certificate -qO- https://api.ip.sb/geoip | grep "\"country_code\":\"CN\"")
if [[ "$geoip" != "" ]];then
  isCN='1'
fi

if [ -f "/usr/bin/apt-get" ];then
    isDebian=`cat /etc/issue|grep Debian`
    apt-get remove docker docker-engine docker.io containerd runc
    apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
    if [ "$isDebian" != "" ];then
        if [ $isCN = "1" ];then
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | sudo apt-key add -
            add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/debian $(lsb_release -cs) stable"
        else
            curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
        fi
    else
        if [ $isCN = "1" ];then
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
            add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
        else
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        fi
    fi
    apt-get install docker-ce
fi

if [ -f "/usr/bin/yum" ];then
    yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
    yum install -y yum-utils device-mapper-persistent-data
    if [ $isCN = "1" ];then
        yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    else
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    fi
    if [ "$1" = '1809' ];then
        yum install -y docker-ce-18.09.9 docker-ce-cli-18.09.9 containerd.io-1.2.13
    else
        yum install -y docker-ce docker-ce-cli
    fi
fi

systemctl start docker

if [ $isCN = "1" ];then
    cat >/etc/docker/daemon.json<<EOF
{
  "live-restore": true,
  "log-level": "warn",
  "log-driver": "local",
  "log-opts": {
    "max-size": "8m"
  }
}
EOF
else
    cat >/etc/docker/daemon.json<<EOF
{
  "live-restore": true,
  "log-level": "warn",
  "log-driver": "local",
  "log-opts": {
    "max-size": "8m"
  }
}
EOF
fi

if [ -f "/usr/bin/yum" ];then
    if [ -f "/etc/selinux/config" ];then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    fi
fi

systemctl enable docker
systemctl restart docker

echo "Done!"