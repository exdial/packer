#cloud-config
autoinstall:
  version: 1
  locale: en_US.UTF-8
  refresh-installer:
    update: no
  keyboard:
    layout: us
  network:
    network:
      version: 2
      ethernets:
        enp0s3:
          dhcp4: true
  identity:
    hostname: ${var.vm_name}
    username: ${var.ssh_username}
    password: ${var.ssh_password_sha256}
  ssh:
    install-server: true
    allow-pw: true
  early-commands:
    - echo "Running early-commands ..."
    - systemctl stop ssh.service
  late-commands:
    - echo "Running late-commands ..."
    - systemctl enable ssh.service
  storage:
    version: 1
    updates: security
    swap:
      size: 0
    layout:
      name: direct
