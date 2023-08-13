#Terrafrom script to run an EC2 instance allowing traffic from & to port 22 from host ip
#instance type t2.micro and region specified

provider "aws" {
  region = "ap-south-1"
}

variable "my_ip" {
    default = "223.178.87.197/32"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_my_ip"
  description = "Allow SSH traffic from my ip"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
}

resource "aws_instance" "my_instance" {
  ami             = "ami-0ded8326293d3201b"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name]
  tags = {
    "Name" = "MyEC2Instance"
  }
}
