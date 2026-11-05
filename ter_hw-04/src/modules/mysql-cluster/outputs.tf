output "cluster_id" {
  description = "ID of the created MySQL cluster"
  value       = yandex_mdb_mysql_cluster.this.id
}

output "cluster_name" {
  description = "Name of the created MySQL cluster"
  value       = yandex_mdb_mysql_cluster.this.name
}