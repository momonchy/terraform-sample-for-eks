## VPC
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-${var.env}-vpc-default"
  }
}


## Subnet
resource "aws_subnet" "public" {
  count             = var.req_subnet_num
  vpc_id            = aws_vpc.default.id
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index + 1)
  availability_zone = "ap-northeast-${var.availability_zones[count.index]}"
  tags = {
    Name = "${var.prefix}-${var.env}-subnet-public-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "internal" {
  count             = var.req_subnet_num
  vpc_id            = aws_vpc.default.id
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index + 11)
  availability_zone = "ap-northeast-${var.availability_zones[count.index]}"
  tags = {
    Name = "${var.prefix}-${var.env}-subnet-internal-${var.availability_zones[count.index]}"
  }
}


## Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "${var.prefix}-${var.env}-igw-default"
  }
}


## Nat Gateway
resource "aws_eip" "nat" {
  count  = var.req_subnet_num
  domain = "vpc"
  tags = {
    Name = "${var.prefix}-${var.env}-eip-natgateway"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.req_subnet_num
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.prefix}-${var.env}-nat-internal-${var.availability_zones[count.index]}"
  }
}


## Routing Table
#### public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "${var.prefix}-${var.env}-rtb-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.req_subnet_num
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

#### internal subnet
resource "aws_route_table" "internal" {
  count  = var.req_subnet_num
  vpc_id = aws_vpc.default.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.prefix}-${var.env}-rtb-internal-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "internal" {
  count          = var.req_subnet_num
  route_table_id = aws_route_table.internal[count.index].id
  subnet_id      = aws_subnet.internal[count.index].id
}


## Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-${var.env}-sg-default"
  }
}


## Output variable
output "vpc_id" {
  value = aws_vpc.default.id
}

output "subnet_public" {
  value = aws_subnet.public.*.id
}

output "subnet_internal" {
  value = aws_subnet.internal.*.id
}

output "default_sg_id" {
  value = aws_default_security_group.default.id
}