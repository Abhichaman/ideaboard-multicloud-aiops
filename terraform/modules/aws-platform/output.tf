output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ap-south-1 --name ${aws_eks_cluster.main.name}"
}

output "database_url" {
  sensitive = true
  value     = "postgresql://postgres:${var.db_password}@${aws_db_instance.postgres.endpoint}/ideaboard"
}