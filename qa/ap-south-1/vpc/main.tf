variable "region" {default = "ap-south-1"}

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket       = "terraforrm-eks-state-files"
    key          = "dev/ap-south-1/vpc/terraform.tfstate"
    region       = "ap-south-1"
  }
}

module "subnet" {
  source      = "git::https://github.com/celigo/infra-terraform.git//modules/subnet/"
  name_prefix = "qa-aws-eks-ap-south-1"
  newbits     = "24"
  subnets_count = "2"
  tags = {

    APPLICATIONENV = "dev"
    SERVICENAME    = "devops"


  }
}

output "subnets_layer1" {
  value = module.subnet.subnets_layer1
}

output "subnets_layer2" {
  value = module.subnet.subnets_layer2
}

output "subnets_public" {
  value = module.subnet.subnets_public
}

data "aws_vpc" "defaultvpc" {

  default = true
}
