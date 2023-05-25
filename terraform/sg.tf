# To get my current IP address and use it on Security Groups
data "http" "myip4" {
  url = "https://ifconfig.me/ip"
}

resource "aws_security_group" "vmix" {
  name        = "${var.name}_sg"
  description = "Allow RDP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Public RDP Connection"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks      = ["${chomp(data.http.myip4.response_body)}/32"]
  }

  ingress {
    description = "Public DCV Connection"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks      = ["${chomp(data.http.myip4.response_body)}/32"]
  }

  ingress {
    description = "Public VMix API Connection"
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks      = ["${chomp(data.http.myip4.response_body)}/32"]
  }

  ingress {
    description = "Ansible Connection"
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks      = ["${chomp(data.http.myip4.response_body)}/32"]
  }

  ingress {
    description = "NDI Tools Bridge TCP"
    from_port   = 5990
    to_port     = 5990
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks      = ["${chomp(data.http.myip4.response_body)}/32"]
  }

  ingress {
    description = "NDI Tools Bridge UDP"
    from_port   = 5990
    to_port     = 5990
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks      = ["${chomp(data.http.myip4.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
