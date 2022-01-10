#/bin/bash

VER='4.3.9' # 4.2.5 4.3.9 with config avaliable, other versions use default password admin:adminadmin

QBUSER='box'  # Default User: box | Password: qbittorrent

RUNUSER='box'  # Systemd run as user
WEBPORT='8081'

CONFURL='https://cdn.jsdelivr.net/gh/hicasper/shell@latest/config/qbittorrent'

while [ $# -gt 0 ]; do
    case $1 in
        uninstall)
            UNINST=1  # Unvailable
            ;;
        -u|--user)
            RUNUSER=$2
            shift
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

HOMEDIR="/root"
if [ "$RUNUSER" != 'root' ]; then
  if [ `id -u $RUNUSER 2>/dev/null || echo -1` -eq -1 ]; then
    useradd -U -m $RUNUSER
    usermod -a -G $RUNUSER $RUNUSER
  fi
  HOMEDIR="/home/$RUNUSER"
fi

case $VER in
  '4.2.5') URL='https://github.com/Aniverse/qbittorrent-nox-static/releases/download/4.2.4/qbittorrent-nox.4.2.5.lt.1.2.6' ;;
  '4.3.9') URL='https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-4.3.9_v1.2.15/x86_64-qbittorrent-nox' ;;
  *) URL='https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox' ;;
esac

wget -O /usr/local/bin/qbittorrent-nox $URL
chmod +x /usr/local/bin/qbittorrent-nox

if [ ! -d "$HOMEDIR/.config/qBittorrent" ]; then
  mkdir -p $HOMEDIR/.config/qBittorrent
fi

wget -O /etc/systemd/system/qbittorrent.service $CONFURL/systemd.service
sed -i "s/RUNUSER/${RUNUSER}/" /etc/systemd/system/qbittorrent.service

if [ ! -z "$VER" ]; then
  wget -O $HOMEDIR/.config/qBittorrent/qBittorrent.conf $CONFURL/$VER.conf
  sed -i "s/QBUSER/${QBUSER}/" $HOMEDIR/.config/qBittorrent/qBittorrent.conf
  sed -i "s/WEBPORT/${WEBPORT}/" $HOMEDIR/.config/qBittorrent/qBittorrent.conf
else
  echo -e "[LegalNotice]\nAccepted=true" > $HOMEDIR/.config/qBittorrent/qBittorrent.conf
fi

if [ "$RUNUSER" != 'root' ]; then
  chown -R $RUNUSER:$RUNUSER $HOMEDIR/.config/qBittorrent
fi

systemctl daemon-reload && systemctl start qbittorrent.service
systemctl enable qbittorrent.service
