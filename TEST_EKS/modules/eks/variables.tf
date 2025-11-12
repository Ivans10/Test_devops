variable "cluster_name" {
  description = "EKS-TEST"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC-EKS-TEST"
  type        = string
}

variable "subnet_ids" {
  description = "ID Subnet EKS-TEST"
  type        = list(string)
}