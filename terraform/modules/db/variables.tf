variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable instance_zone {
  description = "Zone"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
