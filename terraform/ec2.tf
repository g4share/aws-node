locals {
    aws_config = jsondecode(file("aws_config.json"))
    key_name   = format("%s-%s", local.aws_config.tags.Owner, local.aws_config.keyPair.name)
}

provider "aws" {
    region     = local.aws_config.region
}

resource "aws_key_pair" "key_pair" {
    key_name   = local.key_name
    public_key = file(format("%s.pub", local.aws_config.keyPair.file_name))
}

resource "aws_security_group" "ssh_sg" {
    name        = "ssh"
    description = "22/tcp"

    tags = merge(
        local.aws_config.tags,
        { Name = "ssh" }
    )

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

resource "aws_security_group" "kcp_sg" {
    name        = "kcp"
    description = "6443/tcp"

    tags = merge(
        local.aws_config.tags,
        { Name = "kcp" }
    )

    ingress {
        from_port   = 6443
        to_port     = 6443
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

    tags = merge(
        local.aws_config.tags,
        { Name = "web" }
    )

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

resource "aws_instance" "k8s_master" {
    count                  = 1
    ami                    = local.aws_config.ec2.ami
    instance_type          = local.aws_config.ec2.instance_type
    key_name               = local.key_name
    vpc_security_group_ids = [aws_security_group.ssh_sg.id, aws_security_group.kcp_sg.id, aws_security_group.web_sg.id]

    tags = merge(
        local.aws_config.tags,
        { Name = "K8S Master" }
    )

    root_block_device {
        volume_size           = 30
        delete_on_termination = true
        volume_type           = "gp2"
    }

    user_data = templatefile("userdata/duckdns.tpl", {
        duckdns_subdomain = local.aws_config.duckDns.subdomain.master,
        duckdns_token     = local.aws_config.duckDns.token
    })

    provisioner "file" {
        source      = "./k8s"
        destination = "/home/ubuntu/k8s"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/k8s/*.sh",
        ]
    }

    connection {
        type        = "ssh"
        user        = local.aws_config.ec2.user
        private_key = file(local.aws_config.keyPair.file_name)
        host        = self.public_ip
    }
}