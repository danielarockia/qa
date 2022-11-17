variable "region" {default = "ap-south-1"}
variable "env" {default = "qa-aws-eks-ap-south-1"}
  

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket       = "terraforrm-eks-state-files"
    key          = "dev/ap-south-1/iam_role/terraform.tfstate"
    region       = "ap-south-1"
  }
}
module "iamrole" {
  source = "D:\\celigo\\qa\\infra-terraform\\infra-terraform-main\\modules\\iam_roles"
  env = var.env

}