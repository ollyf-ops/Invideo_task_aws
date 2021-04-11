# RDS - Postgres

variable "rds_identifier" {
  default = "db"
}

variable "rds_instance_type" {
  default = "db.m5.large"
}

variable "rds_storage_size" {
  default = "5"
}

variable "rds_engine" {
  default = "postgres"
}

variable "rds_engine_version" {
  default = "11.5"
}

variable "rds_db_name" {
  default = "invideo_db"
}

variable "rds_admin_user" {
  default = "dbadmin"
}

variable "rds_admin_password" {
  default = "super_secret_password"
}

variable "rds_publicly_accessible" {
  default = "false"
}

variable "multi_az" {
  default     = false
  description = "Muti-az allowed?"
}