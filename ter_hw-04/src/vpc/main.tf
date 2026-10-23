resource "yandex_vpc_network" "this" {
  name = var.env_name
}

moved {
  from = yandex_vpc_subnet.this
  to   = yandex_vpc_subnet.for_zone["ru-central1-d"]
}
#task 4 - a subnet for each zone
resource "yandex_vpc_subnet" "for_zone" {
  for_each = { for s in var.subnets : s.zone => s}

  name           = "${var.env_name}-subnet-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [each.value.cidr]

}

# resource "yandex_vpc_subnet" "this" {
#   name           = "${var.env_name}-subnet"
#   zone           = var.zone
#   network_id     = yandex_vpc_network.this.id
#   v4_cidr_blocks = [var.cidr] #list(String)
# }