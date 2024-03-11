locals {
    aws_config = jsondecode(file("aws_config.json"))

    access_key = try(env("AWS_ACCESS_KEY_ID"), local.aws_config.credentials.access_key)
    secret_key = try(env("AWS_SECRET_ACCESS_KEY"), local.aws_config.credentials.secret_key)
}

provider "aws" {
    region     = local.aws_config.region
    access_key = local.access_key
    secret_key = local.secret_key
}

resource "aws_key_pair" "key_pair" {
  key_name   = local.aws_config.keyPair.key_name
  public_key = file(local.aws_config.keyPair.public_key)
}

resource "aws_security_group" "ssh_sg" {
    name        = "ssh"
    description = "22/tcp"
    
    tags = {
        Name = "ssh"
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "web_sg" {
    name        = "web"
    description = "80,443/tcp"

    tags = {
        Name = "web"
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "vnc_sg" {
    name        = "vnc"
    description = "5900/tcp"

    tags = {
        Name = "VNC"
    }

    ingress {
        from_port   = 5900
        to_port     = 5900
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "ec2" {
    ami                    = local.aws_config.ec2.ami
    instance_type          = local.aws_config.ec2.instance_type
    key_name               = aws_key_pair.key_pair.key_name
    vpc_security_group_ids = [aws_security_group.ssh_sg.id, aws_security_group.web_sg.id, aws_security_group.vnc_sg.id]

    root_block_device {
        volume_size           = 10
        delete_on_termination = true
        volume_type           = "gp2"
    }

    user_data = templatefile("script/duckdns.tpl", {
        duckdns_subdomain = local.aws_config.duckDns.subdomain,
        duckdns_token     = local.aws_config.duckDns.token 
    })

    tags = {
        Name = "ETS"
    }
}