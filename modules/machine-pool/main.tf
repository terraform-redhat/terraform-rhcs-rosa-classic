resource "rhcs_machine_pool" "machine_pool" {
  cluster                 = var.cluster_id
  name                    = var.name
  machine_type            = var.machine_type
  replicas                = var.replicas
  autoscaling_enabled     = var.autoscaling_enabled
  min_replicas            = var.min_replicas
  max_replicas            = var.max_replicas
  labels                  = var.labels
  use_spot_instances      = var.use_spot_instances
  max_spot_price          = var.max_spot_price
  taints                  = var.taints
  multi_availability_zone = var.multi_availability_zone
  availability_zone       = var.availability_zone
  subnet_id               = var.subnet_id
}
