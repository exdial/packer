#!/usr/bin/env bash
set -exu

USERNAME="vagrant"
HOME_DIR="/home/${USERNAME}"

errdebug() {
  echo "Entering debug mode"
  echo "Connect via \"ssh vagrant@127.0.0.1 -p 22222\""
  sleep 3600
}

get_vagrant_key() {
  mkdir -p "$HOME_DIR"/.ssh
  curl -s -o "$HOME_DIR"/.ssh/authorized_keys \
  https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub.ed25519
}

if get_vagrant_key; then
  chmod 0700 "$HOME_DIR"/.ssh
  chmod 0600 "$HOME_DIR"/.ssh/authorized_keys
  chown -R $USERNAME:$USERNAME "$HOME_DIR"/.ssh
else
  echo "Download failed!"
  errdebug
fi

apt-get update
DEBIAN_FRONTEND=noninteractive && \
apt-get install -y --no-install-recommends --fix-missing \
ca-certificates open-vm-tools bzip2 tar

snap remove --purge lxd
snap remove --purge core20
snap remove --purge snapd
apt-get --purge autoremove -y snapd
truncate -s 0 /etc/resolv.conf
swapoff -a
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp .bash_history /swap.img
sed -i '/.*swap.*/d' /etc/fstab
