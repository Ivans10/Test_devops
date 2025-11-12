provider "aws" {
  profile = "TEST"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "s3b-test-terraform-state"
    key     = "tf-state/network.tfstate"
    profile = "TEST"
  }
}

#---Modules---#
module "eks_cluster" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

}

module "eks_vpc" {
  source = "./modules/vpc_eks" 

  cidr_block         = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  availability_zone  = "eu-central-1a"
  environment        = "my-eks-env"

}

