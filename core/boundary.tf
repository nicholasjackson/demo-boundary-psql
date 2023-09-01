resource "hcp_boundary_cluster" "boundary" {
  cluster_id = "boundary-cluster"
  username   = var.boundary_admin_user
  password   = random_password.password.result
  tier = "Standard"

  maintenance_window_config {
    day          = "TUESDAY"
    start        = 2
    end          = 12
    upgrade_type = "SCHEDULED"
  }
}
