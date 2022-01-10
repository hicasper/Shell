#/bin/bash

FBADDR='0.0.0.0'
FBPORT='8080'
FBLANG='zh-cn'

# User for WebUI
FBUSER='box'
FBPASS='Pwd@box'

RUNUSER='box'  # Systemd run as user

while [ $# -gt 0 ]; do
    case $1 in
        uninstall)
            UNINST=1  # Unvailable
            ;;
        -u|--user)
            RUNUSER=$2
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

mkdir /tmp/filebrowser
wget -O /tmp/filebrowser/linux-amd64-filebrowser.tar.gz https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz
tar xvzf /tmp/filebrowser/linux-amd64-filebrowser.tar.gz -C /tmp/filebrowser
cp -f /tmp/filebrowser/filebrowser /usr/local/bin/filebrowser
chmod +x /usr/local/bin/filebrowser
rm -rf /tmp/filebrowser

/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db config init
/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db config set --address $FBADDR
/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db config set --port $FBPORT
/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db config set --locale $FBLANG
/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db config set -r $HOMEDIR
/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db config set --log /var/log/filebrowser.log
/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db users add $FBUSER $FBPASS --perm.admin

chown -R $RUNUSER:$RUNUSER /etc/filebrowser

cat > /etc/systemd/system/filebrowser.service <<EOF
[Unit]
Description=Filebrowser Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=$RUNUSER
ExecStart=/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db
WorkingDirectory=$HOMEDIR
Restart=on-failure
# Don't restart in the case of configuration error
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl start filebrowser.service
systemctl enable filebrowser.service
