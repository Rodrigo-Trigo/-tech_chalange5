resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "solidarytech-vpc"
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "solidarytech-igw"
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "solidarytech-public-subnet-a"
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "solidarytech-public-subnet-b"
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "solidarytech-public-rt"
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}