#!/bin/bash -e

# TODO: should be a variable coming in
#       check this line: grep -q BCM2708 /proc/cpuinfo it could help figure if raspberry
echo
echo -n "Is this a Raspberry Pi? [y/N] "
read REPLY
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then
  export AUDIO_RECEIVER_IS_PI="false"
else
  export AUDIO_RECEIVER_IS_PI="true"
fi

read -p "Hostname [$(hostname)]: " HOSTNAME

if [ "$AUDIO_RECEIVER_IS_PI" = "false" ]; then
  sudo hostnamectl set-hostname ${HOSTNAME:-$(hostname)}
else
  sudo raspi-config nonint do_hostname ${HOSTNAME:-$(hostname)}
fi

CURRENT_PRETTY_HOSTNAME=$(hostnamectl status --pretty)
read -p "Pretty hostname [${CURRENT_PRETTY_HOSTNAME:-FooBar}]: " PRETTY_HOSTNAME
sudo hostnamectl set-hostname --pretty "${PRETTY_HOSTNAME:-${CURRENT_PRETTY_HOSTNAME:-FooBar}}"

echo "Updating packages"
sudo apt update
sudo apt upgrade -y

echo "Installing components"

sudo ./install-bluetooth.sh
sudo ./install-shairport.sh
sudo ./install-spotify.sh
sudo ./install-upnp.sh
sudo ./install-snapcast-client.sh
sudo ./install-pivumeter.sh
sudo ./enable-hifiberry.sh
sudo ./enable-read-only.sh
