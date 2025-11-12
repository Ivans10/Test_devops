output "eks_vpc_id" {
  value = module.eks_vpc.vpc_id
}

output "eks_public_subnet_id" {
  value = module.eks_vpc.public_subnet_id
}