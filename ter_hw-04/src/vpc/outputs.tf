#task 4 - a subnet for each zone
output "vpc" {
  description = "VPC module result: network and subnets for each zone"
  value = {
    network_id     = yandex_vpc_network.this.id
    network_name   = yandex_vpc_network.this.name
    subnets = {
        for zone, subnet in yandex_vpc_subnet.for_zone : zone => {
            id   = subnet.id
            name = subnet.name
            zone = subnet.zone
            cidr = subnet.v4_cidr_blocks
        }
    }
    subnet_ids = [for s in yandex_vpc_subnet.for_zone : s.id]
    subnet_zones = [for s in yandex_vpc_subnet.for_zone : s.zone]
  }
}

# output "vpc" {
#   description = "VPC module result: subnet object, IDs, and key attributes"
#   value = {
#     subnet         = yandex_vpc_subnet.this
#     subnet_id      = yandex_vpc_subnet.this.id
#     subnet_name    = yandex_vpc_subnet.this.name
#     subnet_zone    = yandex_vpc_subnet.this.zone
#     subnet_cidr    = yandex_vpc_subnet.this.v4_cidr_blocks
#     network_id     = yandex_vpc_network.this.id
#     network_name   = yandex_vpc_network.this.name
#   }
# }