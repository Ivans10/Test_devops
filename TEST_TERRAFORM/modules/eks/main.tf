provider "aws" {
  region = "eu-north-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
resource "aws_eks_cluster" "eks_test" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_eks_node_group" "worker" {
  cluster_name    = aws_eks_cluster.eks_test.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.NGW-EIP-A.id
  subnet_id     = aws_subnet.EGRESS-PUBLIC-A.id

  tags = {
    Name = join("", [var.prefix_name, "-egress-ngw"])
  }

  depends_on = [aws_internet_gateway.EGRESS-IGW]
}

resource "aws_internet_gateway" "EGRESS-IGW" {
  vpc_id = aws_vpc.EGRESS-VPC.id

  tags = merge(var.default_tags, {
    Name = join("", [var.prefix_name, "-egress-igw"])
  })
}

resource "aws_route_table" "EGRESS-PUBLIC-RT" {
  vpc_id = aws_vpc.EGRESS-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.EGRESS-IGW.id
  }
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = var.transit_gateway_id
  }
  route {
    cidr_block         = "172.16.0.0/12"
    transit_gateway_id = var.transit_gateway_id
  }
  route {
    cidr_block         = "192.168.0.0/16"
    transit_gateway_id = var.transit_gateway_id
  }
  tags = merge(var.default_tags, {
    Name = join("", [var.prefix_name, "-egress-public-rt"])
  })
}