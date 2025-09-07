output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "cluster_security_group" { value = module.eks.cluster_security_group_id }
output "node_role_name" { value = try(module.eks.eks_managed_node_groups["default"].iam_role_name, null) }
