output "vpc" {
  description = "VPC module result: subnet object, IDs, and key attributes"
  value = {
    subnet         = yandex_vpc_subnet.this
    subnet_id      = yandex_vpc_subnet.this.id
    subnet_name    = yandex_vpc_subnet.this.name
    subnet_zone    = yandex_vpc_subnet.this.zone
    subnet_cidr    = yandex_vpc_subnet.this.v4_cidr_blocks
    network_id     = yandex_vpc_network.this.id
    network_name   = yandex_vpc_network.this.name
  }
}