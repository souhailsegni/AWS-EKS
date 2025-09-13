resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name       = "${var.cluster_name}-vpc"
    Terraform  = "true"
    Environment = "demo"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(slice(data.aws_availability_zones.available.names, 0, var.az_count))

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnet_cidrs, index(data.aws_availability_zones.available.names, each.value))
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-${each.value}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(slice(data.aws_availability_zones.available.names, 0, var.az_count))

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.private_subnet_cidrs, index(data.aws_availability_zones.available.names, each.value))
  availability_zone       = each.value
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private-${each.value}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.cluster_name}-nat"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow all traffic within the cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}
