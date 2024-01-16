# Create a VPC
resource "aws_vpc" "b3_gr3_main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "b3_gr3_main" {
  vpc_id = aws_vpc.b3_gr3_main.id
}

# Create a route table and a public route to the internet through the internet gateway
resource "aws_route_table" "b3_gr3_main" {
  vpc_id = aws_vpc.b3_gr3_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.b3_gr3_main.id
  }
}

# Retrieve the availability zones
data "aws_availability_zones" "b3_gr3_available" {
  state = "available"
}

# Create a public subnet in the first availability zone
resource "aws_subnet" "b3_gr3_public" {
  availability_zone = data.aws_availability_zones.b3_gr3_available.names[0]
  cidr_block        = cidrsubnet(aws_vpc.b3_gr3_main.cidr_block, 8, 0)
  vpc_id            = aws_vpc.b3_gr3_main.id
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "b3_gr3_public_subnet" {
  subnet_id      = aws_subnet.b3_gr3_public.id
  route_table_id = aws_route_table.b3_gr3_main.id
}
