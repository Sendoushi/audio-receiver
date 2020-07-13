#!/bin/bash -e

AUDIO_RECEIVER_IS_PI=$1

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo
echo -n "Do you want to install Snapcast client (snapclient})? [y/N] "
read REPLY
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then exit 1; fi

apt install --no-install-recommends -y snapclient
