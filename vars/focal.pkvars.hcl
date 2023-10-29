iso_url      = "https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso"
iso_checksum = "file:http://releases.ubuntu.com/20.04/SHA256SUMS"
vm_name      = "focal"
headless     = true
boot_command = [
  "<tab><tab><tab><tab><tab><wait>",
  "<esc><wait><f6><wait><esc><wait>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
  "/casper/vmlinuz <wait>",
  "initrd=/casper/initrd autoinstall <wait>",
  "quiet fsck.mode=skip <wait>",
  "systemd.unified_cgroup_hierarchy=0 <wait>",
  "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait3>",
  "<enter>"
]
