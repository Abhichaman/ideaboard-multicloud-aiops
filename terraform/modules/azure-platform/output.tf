output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kubeconfig_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --overwrite-existing"
}

output "database_url" {
  sensitive = true
  value     = "postgresql://pgadmin:${var.db_password}@${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/ideaboard?sslmode=require"
}