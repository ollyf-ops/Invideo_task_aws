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
  description = "Ubuntu Server 18.04 LTS (HVM)"
  type        = map

  default = {
    "us-east-1" = "ami-0b6ed4dfa25917eb2"
  }
}

variable "public_subnets_cidr" {
  type = list
  default = ["172.31.0.0/24", "172.31.2.0/24", "172.31.4.0/24"]
}

variable "private_subnets_cidr" {
  type = list
  default = ["172.31.1.0/24", "172.31.3.0/24", "172.31.5.0/24"]
}

variable "ec2_publicly_accessible" {
  default = "false"
}
