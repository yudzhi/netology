module "mysql_cluster" {
  source = "./modules/mysql-cluster"

  cluster_name = "example"
  network_id   = module.vpc_dev.vpc.network_id
  subnet_id    = module.vpc_dev.vpc.subnet_ids[0]
  zone         = module.vpc_dev.vpc.subnet_zones[0]
  ha           = true   # сначала один хост
}

module "mysql_db_user" {
  source = "./modules/mysql-db-user"

  cluster_id    = module.mysql_cluster.cluster_id
  database_name = "test"
  user_name     = "app"
  user_password = var.mysql_app_password
}