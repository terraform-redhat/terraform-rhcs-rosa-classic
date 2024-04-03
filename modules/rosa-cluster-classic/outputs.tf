output "cluster_id" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.id
  description = "Unique identifier of the cluster."
}

output "api_url" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.api_url
  description = "URL of the API server."
}

output "console_url" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.console_url
  description = "URL of the console."
}

output "domain" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.domain
  description = "DNS domain of cluster."
}

output "infra_id" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.infra_id
  description = "The ROSA cluster infrastructure ID."
}

output "current_version" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.current_version
  description = "The currently running version of OpenShift on the cluster, for example '4.11.0'."
}

output "state" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.state
  description = "The state of the cluster."
}

output "cluster_admin_username" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.admin_credentials == null ? null : rhcs_cluster_rosa_classic.rosa_classic_cluster.admin_credentials.username
  description = "The username of the admin user."
}

output "cluster_admin_password" {
  value       = rhcs_cluster_rosa_classic.rosa_classic_cluster.admin_credentials == null ? null : rhcs_cluster_rosa_classic.rosa_classic_cluster.admin_credentials.password
  description = "The password of the admin user."
  sensitive   = true
}
