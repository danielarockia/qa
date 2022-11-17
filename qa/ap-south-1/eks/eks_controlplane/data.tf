
data "aws_vpc" "defaultvpc" {

  default = true
}

data "aws_subnet_ids" "worker" {
    vpc_id = "${data.aws_vpc.defaultvpc.id}"
  filter {
    name   = "tag:Name"
    values = ["*PUB*"]
  }
}

