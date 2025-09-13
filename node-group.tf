resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng-1"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [for s in aws_subnet.private : s.id]

  scaling_config {
    desired_size = var.node_desired
    max_size     = var.node_max
    min_size     = var.node_min
  }

  instance_types = [var.node_instance_type]
  ami_type       = "AL2_x86_64"

  # Optional SSH Access
  dynamic "remote_access" {
    for_each = var.ssh_key_name != null ? [1] : []
    content {
      ec2_ssh_key = var.ssh_key_name
    }
  }

  labels = {
    nodegroup = "demo"
  }

  tags = {
    Name       = "${var.cluster_name}-ng-1"
    Terraform  = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonSSMManagedInstanceCore,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy
  ]
}
