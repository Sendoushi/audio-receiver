#!/bin/bash -e

AUDIO_RECEIVER_IS_PI=$1
ARCH=armhf # Change to armv6 for Raspberry Pi 1/Zero
FILE_SPOTIFY=spotifyd-linux-${ARCH}-slim.tar.gz

if [ "$AUDIO_RECEIVER_IS_PI" = "false" ]; then
  ARCH=amd64
  FILE_SPOTIFY=spotifyd-linux-slim.tar.gz
fi

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo
echo -n "Do you want to install Spotify Connect (spotifyd)? [y/N] "
read REPLY
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then exit 0; fi

# https://github.com/Spotifyd/spotifyd/releases/download/v0.2.24/spotifyd-linux-${ARCH}-slim.tar.gz
tar -xvzf files/${FILE_SPOTIFY}
mkdir -p /usr/local/bin
mv spotifyd /usr/local/bin

PRETTY_HOSTNAME=$(hostnamectl status --pretty | tr ' ' '-')
PRETTY_HOSTNAME=${PRETTY_HOSTNAME:-$(hostname)}

cat <<EOF > /etc/spotifyd.conf
[global]
backend = alsa
mixer = Softvol
volume-control = softvol # alsa
device_name = ${PRETTY_HOSTNAME}
bitrate = 320
#zeroconf_port = 4444
EOF

cat <<'EOF' > /etc/systemd/system/spotifyd.service
[Unit]
Description=A spotify playing daemon
Documentation=https://github.com/Spotifyd/spotifyd
Wants=network-online.target
After=network.target sound.target

[Service]
Type=simple
ExecStart=/usr/local/bin/spotifyd --no-daemon
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now spotifyd.service
