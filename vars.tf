# Put the following two keys into shell or env variables

variable "aws_access_key" {
  description = "AWS access key, must pass on command line using -var"
}

variable "aws_secret_key" {
  description = "AWS secret access key, must pass on command line using -var"
}

variable "aws_region" {
  description = "US EAST Virginia"
  default     = "us-east-1"
}

# dynamically retrieves all availability zones for current region
#data "aws_availability_zones" "available" {}

# specifying AZs 
#   comment off this "azs" to retrive all AZs dynamically (uncomment the line above "data ...")
variable "azs" {
  type = list
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "ec2_amis" {
  description = "Ubuntu Server 18.04 LTS (HVM) with wordpress"
  type        = map

  default = {
    "us-east-1" = "ami-0478565e56d954357"
  }
}

variable "public_subnets_cidr" {
  type = list
  default = ["172.31.16.0/20", "172.31.48.0/20", "172.31.80.0/20"]
}

variable "private_subnets_cidr" {
  type = list
  default = ["172.31.32.0/20", "172.31.64.0/20", "172.31.96.0/20"]
}

variable "ec2_publicly_accessible" {
  default = "false"
}
