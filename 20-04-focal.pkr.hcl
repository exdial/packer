packer {
  required_version = ">= 1.9.0"

  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "file:http://releases.ubuntu.com/20.04/SHA256SUMS"
}

variable "vm_name" {
  type    = string
  default = "focal"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_password_sha256" {
  type = string
  # First create a salt `openssl rand -base64 9`. Then create a password
  # using the salt `mkpasswd -m sha-512 vagrant -S <output of openssl>`.
  # Encrypted password here is vagrant.
  default = "$6$ihLAVm9evpqz$tqwrwpxQ89UdQtIOdBohtHU/2xrQJ4RgPLpDUXtGc1AGi42U1TFqB2oupVOSdnfXvMPREVb1uL/E0lr37MQ840"
}

variable "ssh_forwarded_port" {
  type    = string
  default = "22222"
}

# Cloud-init will try to find "user-data" and "meta-data" files
# right after the root location "/", so it is extremely important to use
# the following datasource format: http://{{ .HTTPIP }}:{{ .HTTPPort }}/
# Otherwise, cloud-init ignores "user-data" file and will use its own
# fallback datasource.
source "virtualbox-iso" "ubuntu" {
  vm_name       = var.vm_name
  guest_os_type = "Ubuntu_64"
  headless      = true

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_port               = 22
  ssh_timeout            = "20m"
  ssh_handshake_attempts = "40"
  host_port_min          = var.ssh_forwarded_port
  host_port_max          = var.ssh_forwarded_port

  cpus      = "2"
  memory    = "2048"
  disk_size = "7000"
  format    = "ova"

  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  output_directory = "builds"

  # Instead of keeping an empty meta-data file in the repository,
  # serve the empty location "/meta-data" by HTTP.
  http_content = {
    "/user-data" = templatefile("http/user-data.pkrtpl.hcl", { var = var }),
    "/meta-data" = ""
  }

  guest_additions_mode = "upload"
  guest_additions_path = "/tmp/VBoxGuestAdditions.iso"

  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--rtcuseutc", "off"],
    ["setextradata", "{{ .Name }}", "GUI/SuppressMessages", "all"],
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
    # Scale factor can be useful when debugging with the GUI enabled,
    # when `headless = false`.
    ["setextradata", "{{ .Name }}", "GUI/ScaleFactor", "2.20"]
  ]
  boot_wait              = "5s"
  boot_keygroup_interval = "500ms"
  boot_command = [
    "<tab><tab><tab><tab><tab><wait>",
    "<esc><wait><f6><wait><esc><wait>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "/casper/vmlinuz <wait>",
    "initrd=/casper/initrd autoinstall <wait>",
    "quiet fsck.mode=skip net.ifnames=0 <wait>",
    "biosdevname=0 systemd.unified_cgroup_hierarchy=0 <wait>",
    "ds=nocloud-net;s=http://{{.HTTPIP}}:{{ .HTTPPort }}/ ---<wait3>",
    "<enter>"
  ]
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    inline_shebang  = "/bin/sh -exu"
    inline = [
      "echo '${var.ssh_username} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/${var.ssh_username}",
      "chmod 0440 /etc/sudoers.d/${var.ssh_username}"
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    scripts = [
      "http/provision.sh"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    compression_level   = 9
    output              = "output/{{ .Provider }}-ubuntu-20-04.box"
  }
}
