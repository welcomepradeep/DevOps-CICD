##########################################################
# Jenkins EC2 Instance
##########################################################

resource "aws_instance" "jenkins" {

  ami                         = var.ami_id
  instance_type               = var.jenkins_instance_type
  subnet_id                   = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  associate_public_ip_address = true
  key_name                    = var.key_name

  ##########################################################
  # IAM Role
  ##########################################################

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  ##########################################################
  # Monitoring
  ##########################################################

  monitoring   = true
  ebs_optimized = true

  ##########################################################
  # Root Volume
  ##########################################################

  root_block_device {

    volume_type           = "gp3"
    volume_size           = var.jenkins_volume_size
    delete_on_termination = true
    encrypted             = true

  }

  ##########################################################
  # Instance Metadata (IMDSv2)
  ##########################################################

  metadata_options {

    http_endpoint = "enabled"
    http_tokens   = "required"

  }

  ##########################################################
  # Tags
  ##########################################################

  tags = {

    Name        = local.jenkins_name
    Project     = local.project_name
    Environment = local.environment
    Server      = "Jenkins"
    ManagedBy   = "Terraform"

  }

  ##########################################################
  # Lifecycle
  ##########################################################

  lifecycle {

    create_before_destroy = true

  }

  depends_on = [

    aws_internet_gateway.igw,
    aws_route_table_association.public

  ]

}

##########################################################
# Web Server
##########################################################

resource "aws_instance" "web" {

  ami                         = data.aws_ami.rhel9.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  associate_public_ip_address = true
  key_name                    = var.key_name

  ##########################################################
  # IAM Role
  ##########################################################

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  ##########################################################
  # Monitoring
  ##########################################################

  monitoring   = true
  ebs_optimized = true

  ##########################################################
  # Root Volume
  ##########################################################

  root_block_device {

    volume_type           = "gp3"
    volume_size           = var.web_volume_size
    delete_on_termination = true
    encrypted             = true

  }

  ##########################################################
  # Instance Metadata (IMDSv2)
  ##########################################################

  metadata_options {

    http_endpoint = "enabled"
    http_tokens   = "required"

  }

  ##########################################################
  # Tags
  ##########################################################

  tags = {

    Name        = local.web_name
    Project     = local.project_name
    Environment = local.environment
    Server      = "Application"
    ManagedBy   = "Terraform"

  }

  ##########################################################
  # Lifecycle
  ##########################################################

  lifecycle {

    create_before_destroy = true

  }

  depends_on = [

    aws_internet_gateway.igw,
    aws_route_table_association.public

  ]

}
