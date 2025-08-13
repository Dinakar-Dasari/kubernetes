resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"  
  tags = {
    Name = "eks_terraform"
  }
}

resource "aws_subnet" "private" {
  count = length(var.cidr_private)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_private[count.index]
  availability_zone = local.availability_zone[count.index]
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_subnet" "public" {
  count = length(var.cidr_public)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_public[count.index]
  availability_zone = local.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


## Route tables for traffic flow

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public_route"
  }
}

resource "aws_route_table" "private_subnet" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private_route"
  }
}

## route for traffic flow

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public_subnet.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private_subnet.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.main.id
}

## route association to subnets

resource "aws_route_table_association" "public_subnets" {
  count = length(var.cidr_public)      
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_route_table_association" "private_subnets" {
  count = length(var.cidr_private)      
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_subnet.id
}