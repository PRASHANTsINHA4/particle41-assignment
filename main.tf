terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_new.endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_new.certificate_authority[0].data)
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.eks_new.name
}

# VPC
resource "aws_vpc" "vpc_new" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnets
resource "aws_subnet" "public_subnet_1_new" {
  vpc_id                  = aws_vpc.vpc_new.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
}

resource "aws_subnet" "public_subnet_2_new" {
  vpc_id                  = aws_vpc.vpc_new.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"
}

# Private Subnets
resource "aws_subnet" "private_subnet_1_new" {
  vpc_id            = aws_vpc.vpc_new.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "private_subnet_2_new" {
  vpc_id            = aws_vpc.vpc_new.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-2b"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_new.id
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_new.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1_new.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2_new.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway for Private Subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1_new.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_new.id
}

resource "aws_route" "private_nat_gateway_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1_new.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2_new.id
  route_table_id = aws_route_table.private_rt.id
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "eks_new" {
  name     = "simpletimes-cluster-new"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1_new.id,
      aws_subnet.public_subnet_2_new.id,
      aws_subnet.private_subnet_1_new.id,
      aws_subnet.private_subnet_2_new.id
    ]
  }
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# EKS Node Group
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_new.name
  node_group_name = "simpletimes-nodegroup"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [aws_subnet.private_subnet_1_new.id, aws_subnet.private_subnet_2_new.id]
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
}
resource "kubernetes_deployment" "app_new" {
  metadata {
    name = "simpletime-services-new"
    labels = {
      app = "simpletime-services-new"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "simpletime-services-new"
      }
    }
    template {
      metadata {
        labels = {
          app = "simpletime-services-new"
        }
      }
      spec {
        container {
          image = "prassinha13/particle41-webapp:latest"
          name  = "simpletime-containers-new"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

# Kubernetes service for the new deployment
resource "kubernetes_service" "app_service_new" {
  metadata {
    name = "simpletime-services-new"
  }
  spec {
    selector = {
      app = "simpletime-services-new"
    }
    port {
      port        = 80
      target_port = 5000
    }
    type = "LoadBalancer"
  }
}
