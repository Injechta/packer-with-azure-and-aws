# Create SSH key
resource "tls_private_key" "b3_gr3_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "b3_gr3_private_ssh_key" {
  content         = tls_private_key.b3_gr3_ssh_key.private_key_pem
  filename        = "${path.module}/ssh/b3_gr3_private_key.pem"
  file_permission = "0600"
}

# Upload SSH key to AWS
resource "aws_key_pair" "b3_gr3_ec2" {
  key_name   = "b3_gr3_key"
  public_key = tls_private_key.b3_gr3_ssh_key.public_key_openssh
}

# Create a security group to allow SSH and HTTP(s) traffic
resource "aws_security_group" "b3_gr3_ec2" {
  name        = "${local.group}-ec2"
  vpc_id      = aws_vpc.b3_gr3_main.id
  description = "Protect the EC2 instance"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.group_ip_list
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.group_ip_list
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.group_ip_list
  }

  egress {
    description = "Allow All outgoing Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data to retrieve the latest Ubuntu AMI
data "aws_ami" "b3_gr3_ubuntu" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "^b3-gr3-ubuntu-.*"

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data to retrieve the latest Debian AMI
data "aws_ami" "b3_gr3_debian" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "^b3-gr3-debian-.*"

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



# Create an AWS instance with the latest Ubuntu AMI
resource "aws_instance" "b3_gr3_ubuntu_instance" {
  ami                         = data.aws_ami.b3_gr3_ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.b3_gr3_ec2.key_name
  vpc_security_group_ids      = [aws_security_group.b3_gr3_ec2.id]
  subnet_id                   = aws_subnet.b3_gr3_public.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.group}-ubuntu"
  }
}

# Create an AWS Debian instance with the latest Debian AMI
resource "aws_instance" "b3_gr3_debian_instance" {
  ami                         = data.aws_ami.b3_gr3_debian.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.b3_gr3_ec2.key_name
  vpc_security_group_ids      = [aws_security_group.b3_gr3_ec2.id]
  subnet_id                   = aws_subnet.b3_gr3_public.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.group}-debian"
  }
}
