# RDS - Postgres

variable "rds_identifier" {
  default = "db"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "rds_storage_size" {
  default = "5"
}

variable "max_allocated_storage" {
  default = "25"
}

variable "port" {
  default = "3306"
}

variable "rds_engine" {
  default = "mysql"
}

variable "rds_engine_version" {
  default = "5.7.21"
}

variable "rds_db_name" {
  default = "mysqldb"
}

variable "rds_admin_user" {
  default = "dbadmin"
}

variable "rds_admin_password" {
  default = "admin12345"
}

variable "rds_publicly_accessible" {
  default = "false"
}

variable "multi_az" {
  default     = true
  description = "Muti-az allowed?"
}

variable "environment" {
  default = "dev"
}