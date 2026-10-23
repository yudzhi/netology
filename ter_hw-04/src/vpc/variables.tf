variable "env_name" {
  type        = string
  description = "VPC network&subnet name"
}

#Task 4 - a subnet for each zone
variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "List of subnets to create: { zone = string, cidr = string }"
}

# variable "zone" {
#   type        = string
#   description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope (ru-central1-a)"
# }

# variable "cidr" {
#   type        = string
#   description = "CIDR block for the subnet (10.0.1.0/24)"
# }
