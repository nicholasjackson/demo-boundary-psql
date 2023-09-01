output "boundary_server_url" {
  value = hcp_boundary_cluster.boundary.cluster_url
}

output "boundary_worker_public_ip" {
  value = aws_instance.worker.public_ip
}

output "boundary_admin" {
  value = var.boundary_admin_user
}

output "boundary_password" {
  sensitive = true
  value = random_password.password.result
}

output "postgres_endpoint" {
  value = aws_rds_cluster_endpoint.static.endpoint
}

output "postgres_user" {
  value = aws_rds_cluster.postgres.master_username
}

output "postgres_password" {
  sensitive = true
  value = random_password.db_password.result
}