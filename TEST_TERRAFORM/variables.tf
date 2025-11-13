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

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet 10.0.1.0/24"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the subnet."
  type        = string
}

variable "environment" {
  description = "Environment name TEST."
  type        = string
}

variable "prefix_name" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

variable "allocated_storage" {
  description = "RDS-storage"
  type        = string
}

variable "db_name" {
  description = "RDS-TEST"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC-RDS-TEST"
  type        = string
}

variable "subnet_ids" {
  description = "ID Subnet RDS-TEST"
  type        = list(string)
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet 10.0.1.0/24"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the subnet."
  type        = string
}

variable "environment" {
  description = "Environment name TEST."
  type        = string
}

variable "prefix_name" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "default_tags" {
  type = map(string)
}