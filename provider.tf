provider "aws" {
  #access_key = "${var.aws_access_key}"
  #secret_key = "${var.aws_secret_key}"
  profile = "sunny"
  region  = var.aws_region
}

data "aws_vpc" "selected" {
  default = true
}

locals {
  vpc_id    = data.aws_vpc.selected.id
}
