variable "cluster_id" {
  type        = string
  description = "ID of the existing MySQL cluster"
}

variable "database_name" {
  type        = string
  description = "Name of the database to create"
}

variable "user_name" {
  type        = string
  description = "Name of the user to create"
}

variable "user_password" {
  type        = string
  sensitive   = true
  description = "Password for the user"
}