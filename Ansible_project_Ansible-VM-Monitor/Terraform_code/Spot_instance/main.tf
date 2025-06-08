# Fetch the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server*"] # For Ubuntu Instance.
    #values = ["amzn2-ami-hvm-*-x86_64*"] # For Amazon Instance.
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical owner ID for Ubuntu AMIs
  # owners = ["137112412989"] # Amazon owner ID for Amazon Linux AMIs
}

# IAM role for Ansible Master
resource "aws_iam_role" "ansible_master_role" {
  name = "ansible-master-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = {
    Name = "ansible-master-role"
  }
}

# IAM policy for Ansible Master
resource "aws_iam_policy" "ansible_master_policy" {
  name        = "ansible-master-policy"
  description = "Policy for Ansible master to discover and communicate with agents"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ansible_master_policy_attach" {
  role       = aws_iam_role.ansible_master_role.name
  policy_arn = aws_iam_policy.ansible_master_policy.arn
}

# Instance profile for Ansible Master role
resource "aws_iam_instance_profile" "ansible_master_profile" {
  name = "ansible-master-profile"
  role = aws_iam_role.ansible_master_role.name
}

# Ansible Master instance
resource "aws_instance" "ansible_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "MYLABKEY" #change key name as per your setup
  vpc_security_group_ids = [aws_security_group.ansible-VM-SG.id]
  user_data              = templatefile("./scripts/ansible_master_install.sh", {})
  iam_instance_profile   = aws_iam_instance_profile.ansible_master_profile.name

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.0051"
    }
  }

  tags = {
    Name = "ansible-master"
    Role = "master"
  }

  root_block_device {
    volume_size = 10
  }
}

# Ansible Agent instances
resource "aws_instance" "ansible_agents" {
  count                  = 3
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "MYLABKEY" #change key name as per your setup
  vpc_security_group_ids = [aws_security_group.ansible-VM-SG.id]
  user_data              = templatefile("./scripts/ansible_agent_install.sh", {})

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.0051"
    }
  }

  tags = {
    Name = "ansible-agent-${count.index + 1}"
    Role = "agent"
  }

  root_block_device {
    volume_size = 8
  }
}

resource "aws_security_group" "ansible-VM-SG" {
  name        = "ansible-SG"
  description = "Allow inbound traffic"

  dynamic "ingress" {
    for_each = toset([22, 80, 443, 587])
    content {
      description = "inbound rule for port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "Custom TCP Port Range"
    from_port   = 3000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all internal communication within the security group
  ingress {
    description = "Allow all traffic between Ansible instances"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-VM-SG"
  }
}

output "ansible_master_ip" {
  value       = aws_instance.ansible_master.public_ip
  description = "The public IP of the Ansible master"
}

output "ansible_agents_ips" {
  value       = aws_instance.ansible_agents[*].public_ip
  description = "The public IPs of the Ansible agent instances"
}

output "ansible_master_private_ip" {
  value       = aws_instance.ansible_master.private_ip
  description = "The private IP of the Ansible master"
}

output "ansible_agents_private_ips" {
  value       = aws_instance.ansible_agents[*].private_ip
  description = "The private IPs of the Ansible agent instances"
}