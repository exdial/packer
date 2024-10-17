iso_url                = "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
iso_checksum           = "file:http://releases.ubuntu.com/24.04/SHA256SUMS"
vm_name                = "noble"
headless               = true
ssh_timeout            = "60m"
ssh_handshake_attempts = "90"
boot_command           = [
  "<tab><tab><tab><tab><tab><wait>",
  "c<wait2>",
  "set gfxpayload=keep<enter><wait>",
  "linux /casper/vmlinuz autoinstall <wait>",
  "quiet fsck.mode=skip <wait>",
  "systemd.unified_cgroup_hierarchy=0 <wait>",
  "ds=\"nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" ---<wait3>",
  "<enter><wait>",
  "initrd /casper/initrd<enter><wait>",
  "boot<enter>"
]
