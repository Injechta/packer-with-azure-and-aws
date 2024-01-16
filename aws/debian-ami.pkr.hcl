packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_region" {
  default = "eu-north-1"
}

variable "aws_profile" {
  default = "simplon"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "autogenerated_1" {
  profile                       = var.aws_profile
  region                        = var.aws_region
  instance_type                 = "t3.micro"
  ssh_username                  = "admin"
  ami_name                      = "b3-gr3-debian-${local.timestamp}"
  associate_public_ip_address   = true
  force_delete_snapshot         = true
  tags = {
    Name = "b3-gr3-debian"
  }

  subnet_filter {
    filters = {
      "tag:Class": "build"
      "tag:Type": "public"
      "tag:Name": "b3-packer"
    }
    most_free = true
    random = false
  }

  source_ami_filter {
    filters = {
      name                = "debian-11-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
}

build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "file" {
    source      = "./technocorp.pub"
    destination = "/tmp/technocorp.pub"
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }   

  provisioner "shell" {
    inline = [
    "sudo apt-get update",
    "sudo apt-get install -y snapd",
    "sudo snap install core; sudo snap refresh core",
    "sudo snap install --classic certbot",
    "sudo ln -s /snap/bin/certbot /usr/bin/certbot",
    "sudo apt-get install -y jq apache2 unzip git",
    "sudo usermod -aG sudo admin",
    "sudo mkdir -p /home/admin/.ssh",
    "sudo cp /tmp/technocorp.pub /home/admin/.ssh/authorized_keys",
    "sudo chown admin:admin /home/admin/.ssh/authorized_keys",
    "sudo chmod 600 /home/admin/.ssh/authorized_keys",
    "sudo mv /tmp/index.html /var/www/html/index.html",
    "sudo chown www-data:www-data /var/www/html/index.html",
    "sudo chmod 644 /var/www/html/index.html"
    ]
  }
}