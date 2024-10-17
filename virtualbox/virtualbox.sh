#!/usr/bin/env bash
set -exu

export DEBIAN_FRONTEND=noninteractive

USERNAME="vagrant"
MOUNT_DIR="/tmp/isomount"
HOME_DIR="/home/${USERNAME}"
ISO_FILE="/tmp/VBoxGuestAdditions.iso"

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

mount_guest_additions() {
  mkdir -p "$MOUNT_DIR"
  mount -t iso9660 -o loop "$ISO_FILE" "$MOUNT_DIR"
}

if mount_guest_additions; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y --no-install-recommends --fix-missing \
    ca-certificates gcc make bzip2 tar
  # Hack: VBoxLinuxAdditions.run every time exited with non-zero code,
  # so we will change the exit code to zero with the "true" command
  "$MOUNT_DIR"/VBoxLinuxAdditions.run --nox11 && true
else
  echo "Mounting guest additions ISO failed!"
  errdebug
fi

check_vbox_version() {
  /usr/sbin/VBoxService --version &>/dev/null
}

check_module_loaded() {
  /usr/sbin/lsmod | grep vboxguest &>/dev/null
}

if check_vbox_version && check_module_loaded; then
  umount "$MOUNT_DIR" && \
  rmdir "$MOUNT_DIR" && \
  rm -f "$ISO_FILE"

  # Cleanup
  snap remove --purge lxd
  snap remove --purge core20
  snap remove --purge snapd
  apt-get --purge autoremove -y snapd
  truncate -s 0 /etc/resolv.conf
  swapoff -a
  rm -rf /tmp/*
  rm -f /var/log/wtmp /var/log/btmp .bash_history /swap.img
  sed -i '/.*swap.*/d' /etc/fstab
else
  echo "Installing guest additions failed!"
  errdebug
fi
