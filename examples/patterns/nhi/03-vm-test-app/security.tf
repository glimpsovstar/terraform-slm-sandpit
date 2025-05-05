data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}*"]
  }
}

# data "aws_security_group" "ssh" {
#   filter {
#     name   = "tag:Name"
#     values = ["*${var.deployment_id}-ssh"]
#   }
# }
# data "aws_security_group" "vault" {
#   filter {
#     name   = "tag:Name"
#     values = ["*${var.deployment_id}-vault"]
#   }
# }