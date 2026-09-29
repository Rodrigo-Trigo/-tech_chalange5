resource "aws_eks_cluster" "solidarytech" {
  name     = "fiap-eks5"
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  version  = "1.32"

  vpc_config {
    subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  }

  tags = {
    Name        = "fiap-eks5"
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eks_node_group" "solidarytech_nodes" {
  cluster_name    = aws_eks_cluster.solidarytech.name
  node_group_name = "fiap-eks5-nodes"
  node_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  tags = {
    Name        = "fiap-eks5-nodes"
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }

  depends_on = [aws_eks_cluster.solidarytech]
}