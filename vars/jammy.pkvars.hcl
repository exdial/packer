iso_url = "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
iso_checksum = "file:http://releases.ubuntu.com/22.04/SHA256SUMS"
vm_name = "jammy"
headless = true
boot_command = [
  "<tab><tab><tab><tab><tab><wait>",
  "c<wait2>",
  "set gfxpayload=keep<enter><wait>",
  "linux /casper/vmlinuz autoinstall <wait>",
  "quiet fsck.mode=skip net.ifnames=0 <wait>",
  "biosdevname=0 systemd.unified_cgroup_hierarchy=0 <wait>",
  "ds=\"nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" ---<wait3>",
  "<enter><wait>",
  "initrd /casper/initrd<enter><wait>",
  "boot<enter>"
]
