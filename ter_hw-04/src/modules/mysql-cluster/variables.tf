variable "cluster_name" {
  type        = string
  description = "Name of the MySQL cluster"
}

variable "network_id" {
  type        = string
  description = "The VPC Network ID of subnets which resource attached to"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for cluster hosts (must belong to network_id)"
}

variable "zone" {
  type        = string
  default     = "ru-central1-d"
  description = "Availability zone for hosts"
}

variable "ha" {
  type        = bool
  default     = true
  description = "If true, create 2 hosts (HA); if false, create 1 host"
}

variable "mysql_version" {
  type        = string
  default     = "8.0"
  description = "Version of the MySQL cluster: 5.7, 8.0, 8.4"
}

variable "resource_preset_id" {
  type        = string
  default     = "s3-c2-m8"   # Intel Ice Lake, 2 vCPU 100%, 8 GB RAM
  description = "https://yandex.cloud/ru/docs/managed-mysql/concepts/instance-types"
}

variable "disk_size" {
  type        = number
  default     = 10
  description = "Host disk size in GB https://yandex.cloud/ru/docs/managed-mysql/concepts/storage"
}

variable "environment" {
  type        = string
  default     = "PRESTABLE"
  description = "Cluster environment: PRESTABLE or PRODUCTION"

  validation {
    condition     = contains(["PRESTABLE", "PRODUCTION"], var.environment)
    error_message = "environment must be either PRESTABLE or PRODUCTION"
  }
}

variable "disk_type_id" {
  type        = string
  default     = "network-hdd"
  description = "Disk type (network-hdd, network-ssd): https://yandex.cloud/ru/docs/managed-mysql/concepts/storage"

  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated", "network-ssd-io-m3"], var.disk_type_id)
    error_message = "disk_type_id must be either network-hdd or network-ssd"
  }
}