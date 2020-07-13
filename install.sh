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

sudo ./install-bluetooth.sh $AUDIO_RECEIVER_IS_PI
sudo ./install-shairport.sh $AUDIO_RECEIVER_IS_PI
sudo ./install-spotify.sh $AUDIO_RECEIVER_IS_PI
sudo ./install-upnp.sh $AUDIO_RECEIVER_IS_PI
sudo ./install-snapcast-client.sh $AUDIO_RECEIVER_IS_PI
sudo ./install-pivumeter.sh $AUDIO_RECEIVER_IS_PI
sudo ./enable-hifiberry.sh $AUDIO_RECEIVER_IS_PI
sudo ./enable-read-only.sh $AUDIO_RECEIVER_IS_PI
