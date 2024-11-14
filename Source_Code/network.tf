# VPC for us-east-1

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"  # VPC with a /16 subnet range
  tags = {
    Name = "MainVPC"
  }
}

# Public Subnet in us-east-1a

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"  # Public subnet's CIDR block
  availability_zone       = "${var.aws_region}a"  # Availability zone
  map_public_ip_on_launch = true                # Ensures EC2 instances in this subnet get a public IP
  tags = {
    Name = "PublicSubnet1"
  }
}

# Public Subnet in us-east-1b

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

# Private Subnet in us-east-1a

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"  # Private subnet's CIDR block
  availability_zone       = "${var.aws_region}a"  # Same AZ as the public subnet
  map_public_ip_on_launch = false         # Instances in this subnet will not have public IPs
  tags = {
    Name = "PrivateSubnet1"
  }
}


# VPC for us-west-2

resource "aws_vpc" "west_vpc" {
  provider   = aws.west
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "WestVPC"
  }
}

# Public Subnet in us-west-2a

resource "aws_subnet" "west_public_subnet_1" {
  provider               = aws.west
  vpc_id                 = aws_vpc.west_vpc.id
  cidr_block             = "10.1.1.0/24"
  availability_zone      = "${var.aws_west_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "WestPublicSubnet1"
  }
}

# Public Subnet in us-west-2b 

resource "aws_subnet" "west_public_subnet_2" {
  provider               = aws.west
  vpc_id                 = aws_vpc.west_vpc.id
  cidr_block             = "10.1.2.0/24"
  availability_zone      = "${var.aws_west_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "WestPublicSubnet2"
  }
}

# Private Subnet in us-west-2a

resource "aws_subnet" "west_private_subnet_1" {
  provider          = aws.west
  vpc_id            = aws_vpc.west_vpc.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "${var.aws_west_region}a"

  tags = {
    Name = "WestPrivateSubnet1"
  }
}


# Internet Gateway (IGW) for us-east-1

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

# Public Route Table and Route for us-east-1

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"  # Sends traffic to the internet
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}


# Internet Gateway (IGW) for us-west-2

resource "aws_internet_gateway" "west_igw" {
  provider = aws.west
  vpc_id   = aws_vpc.west_vpc.id
  tags = {
    Name = "WestIGW"
  }
}

# Public Route Table and Route for us-west-2

resource "aws_route_table" "west_public_rt" {
  provider = aws.west
  vpc_id   = aws_vpc.west_vpc.id
  tags = {
    Name = "WestPublicRouteTable"
  }
}

resource "aws_route" "west_internet_access" {
  provider               = aws.west
  route_table_id         = aws_route_table.west_public_rt.id
  destination_cidr_block = "0.0.0.0/0"  # Sends traffic to the internet
  gateway_id             = aws_internet_gateway.west_igw.id
}

resource "aws_route_table_association" "west_public_subnet_assoc_1" {
  provider       = aws.west
  subnet_id      = aws_subnet.west_public_subnet_1.id
  route_table_id = aws_route_table.west_public_rt.id
}

resource "aws_route_table_association" "west_public_subnet_assoc_2" {
  provider       = aws.west
  subnet_id      = aws_subnet.west_public_subnet_2.id
  route_table_id = aws_route_table.west_public_rt.id
}