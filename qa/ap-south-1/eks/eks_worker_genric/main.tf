variable "region" {default = "ap-south-1"} #Needtomodify
variable "cluster_name" {default = "qa-aws-eks-ap-south-1"} #Needtomodify
variable "asg_prefix" {default = "qa-aws-eks-ap-south-1"} #Needtomodify
variable "keyname" {default = "deveks"} #Needtomodify
variable "cluster_env" {default = "qa-aws-eks-ap-south-1"} #Needtomodify
variable "servicename" {default = "eksworker"}
variable "alertgroup" {default = "devops_team"}
variable "root_volume_size" {default = "100"}
variable "root_volume_type" {default = "gp3"}
variable "worker_asg_role" {default = "AWSServiceRoleForAutoScaling"}
variable "term_policy" {default = "OldestLaunchConfiguration"}
variable "min_instance_count" {default = "1"}
variable "max_instance_count" {default = "2"}
variable "desired_instance_count" { default = "1"}
variable "ami" {default = "amazon-eks-node-1.22-v*"}
variable "vpc_id" {default = "vpc-957588fe"}
variable "instance_type" {default = "t3.xlarge" }
variable "kubelet_args" {default = "--use-max-pods 205"}

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket       = "terraforrm-eks-state-files"
    key          = "dev/ap-south-1/eks/eks_worker_genric/terraform.tfstate"
    region       = "ap-south-1"
  }
}

data "aws_iam_role" "EKSWorkerRole" {
  name = "${var.cluster_env}_EKSWorkerRole"
}


data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["${var.ami}"]
  }

  most_recent = true
  owners      = ["602401143452", "151742754352"] # Amazon Account ID
}

data "aws_subnet_ids" "worker" {
  vpc_id = "${data.aws_vpc.defaultvpc.id}"

  tags = {
    Name = "WORKER-LAYER*"
  }
} 

module "eks_workers" {  
  source = "D:\\celigo\\qa\\infra-terraform\\infra-terraform-main\\modules\\eks_workers_generic"
  asg_prefix    = "${var.asg_prefix}"
  cluster_name    = "${var.cluster_name}"
  alertgroup     = "${var.alertgroup}"
  instance_type  = "${var.instance_type}"
  keyname        = "${var.keyname}"
  kubelet_args   = "${var.kubelet_args}"
  ami            = "${data.aws_ami.eks_worker.id}"
  cluster_env    = "${var.cluster_env}"
  servicename    = "${var.servicename}"
  root_volume_size = "${var.root_volume_size}"
  root_volume_type = "${var.root_volume_type}"
  worker_subnets = ["${data.aws_subnet_ids.worker.ids}"]
  worker_asg_role = "${var.worker_asg_role}"
  term_policy     = "${var.term_policy}"
  worker_iam_role =  "${data.aws_iam_role.EKSWorkerRole.name}"
  min_instance_count = "${var.min_instance_count}"
  max_instance_count = "${var.max_instance_count}"
  desired_instance_count = "${var.desired_instance_count}"
}
