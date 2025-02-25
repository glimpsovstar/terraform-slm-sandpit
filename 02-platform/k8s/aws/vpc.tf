data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}*"]
  }
}

data "aws_subnets" "all" {
  filter {
    name   = "tag:Name"
    values = ["*${var.deployment_id}*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*${var.deployment_id}-private*"]
  }
}