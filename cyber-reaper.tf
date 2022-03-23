locals {
  region             = "eu-central-1"
  key_name           = ""
  instance_count     = 5
  instance_type      = "t2.micro"
  ami_name           = "ami-0a75e2187a559cbc9" # this is AMI for AZ eu-central-1
  instance_user_name = "ec2-user"
  aws_key            = ""
  aws_secret         = ""
}

# DO NOT EDIT UNDER THIS LINE

provider "aws" {
  access_key = local.aws_key
  secret_key = local.aws_secret
  region     = local.region
}

resource "aws_security_group" "cyber_reaper_sg" {
  name = "cyber_reaper_sg"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cyber-reaper" {
  count                  = local.instance_count
  ami                    = local.ami_name
  instance_type          = local.instance_type
  key_name               = local.key_name
  vpc_security_group_ids = ["${aws_security_group.cyber_reaper_sg.id}"]

  provisioner "remote-exec" {
    inline = [
      "sudo docker pull egideon/cyber-reaper:latest",
      "sudo docker run -d --rm --dns 8.8.8.8 --name CyberSpaceBot egideon/cyber-reaper -a 1 -t 1000 -c 80"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = local.instance_user_name
      private_key = file("${local.key_name}.pem")
      timeout     = "4m"
    }
  }
}
