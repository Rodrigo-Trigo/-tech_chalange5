output "eks_cluster_name" {
  description = "Nome do cluster EKS criado"
  value       = aws_eks_cluster.solidarytech.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint da API do cluster EKS"
  value       = aws_eks_cluster.solidarytech.endpoint
}

output "configure_kubectl" {
  description = "Comando para configurar o kubectl"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${aws_eks_cluster.solidarytech.name}"
}
output "ecr_ngo_service_url" {
  value = aws_ecr_repository.ngo_service.repository_url
}

output "ecr_donation_service_url" {
  value = aws_ecr_repository.donation_service.repository_url
}

output "ecr_volunteer_service_url" {
  value = aws_ecr_repository.volunteer_service.repository_url
}

output "ngo_rds_endpoint" {
  value = aws_db_instance.ngo_rds.endpoint
}

output "donation_rds_endpoint" {
  value = aws_db_instance.donation_rds.endpoint
}