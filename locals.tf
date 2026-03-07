locals {
  cluster_mode_enabled = var.num_node_groups > 0

  # Determine cluster mode specific parameter
  cluster_mode_parameters = local.cluster_mode_enabled ? {
    "cluster-enabled" = "yes"
  } : {}

  # Merge custom parameters with cluster mode parameter
  all_parameters = merge(local.cluster_mode_parameters, var.custom_parameters)

  # Tags applied to all resources
  default_tags = merge(
    {
      Name      = var.name
      Terraform = "true"
    },
    var.tags,
  )
}
