# modules/eks/outputs.tf
# Output del modulo EKS
output "cluster_id" {
  description = "ID del cluster EKS"
  value       = aws_eks_cluster.eks_test.id
}

output "cluster_endpoint" {
  description = "Endpoint del cluster EKS"
  value       = aws_eks_cluster.eks_test.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Dati dell'autorità di certificazione del cluster"
  value       = aws_eks_cluster.eks_test.certificate_authority[0].data
}