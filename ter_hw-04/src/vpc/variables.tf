variable "env_name" {
  type        = string
  description = "VPC network&subnet name"
}

variable "zone" {
  type        = string
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope (ru-central1-a)"
}

variable "cidr" {
  type        = string
  description = "CIDR block for the subnet (10.0.1.0/24)"
}
