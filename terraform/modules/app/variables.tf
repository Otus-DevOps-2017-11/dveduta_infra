variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable instance_zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
