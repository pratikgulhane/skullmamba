# provider 
provider "aws" {
  region     = "us-west-1"
  access_key = "AKIASBZAJUCCK4KYZVVF"
  secret_key = "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"
}

#ssh-key
resource "aws_key_pair" "key_TF" {
  key_name   = "key_TF"
  public_key = file("${path.module}/id_rsa.pub")
}

# resource ec2 
resource "aws_instance" "web" {
  ami                    = "ami-0d50e5e845c552faf"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_TF.key_name
  vpc_security_group_ids = ["${aws_security_group.SG_TF.id}"]
  tags = {
    Name = "terra-ec2"
  }
  user_data = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
echo "THIS IS YOUR NGINX PAGE" > /var/www/html/index.nginx-debian.html 
EOF                                              
}

#security group
resource "aws_security_group" "SG_TF" {
  name        = "SG_TF"
  description = "Allow TLS inbound traffic"

  dynamic "ingress" {
    for_each = [22, 80, 443, 3306, 8080]
    iterator = port
    content {
      description = "TLS From VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}