variable "cluster_env" {default = "qa-aws-eks-ap-south-1"} #Needtomodify (it should be same as what we give 'env' variable in iam main.tf)
variable "region" {default = "ap-south-1"} #Needtomodify
variable "cluster_name" {default = "qa-aws-eks-ap-south-1"} #Needtomodify
variable "servicename" {default = "eksworker"}

variable "alertgroup" {default = "devops_team"}

data "aws_iam_role" "ControlPlaneRole" {
  name = "${var.cluster_env}_EKSControlPlaneRole"
}

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket       = "terraforrm-eks-state-files"
    key          = "dev/ap-south-1/eks/eks_controlplane/terraform.tfstate"
    region       = "ap-south-1"
  }
}

module "eks_controlplane_generic" {
  source                = "git::https://github.com/celigo/infra-terraform.git//modules/eks_controlplane_generic/"
  name_prefix           = var.cluster_name
  k8s_version           = "1.23"
  private_endpoint      = false
  public_endpoint       = true
  servicename           = "eksworker"
  worker_subnets        = ["${data.aws_subnet_ids.worker.ids}"]
  cluster_env           = var.cluster_env
  controlplane_iam_role = data.aws_iam_role.ControlPlaneRole.name
  alertgroup = var.alertgroup
  vpc_id = "${data.aws_vpc.defaultvpc.id}"
}