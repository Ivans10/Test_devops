variable "cluster_name" {
  description = "Nome del cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID della VPC dove creare il cluster"
  type        = string
}

variable "subnet_ids" {
  description = "ID delle subnet per il cluster"
  type        = list(string)
}