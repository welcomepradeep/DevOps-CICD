##########################################################
# Jenkins EC2 Instance
##########################################################

resource "aws_instance" "jenkins" {

  ami                    = data.aws_ami.rhel9.id

  instance_type          = var.jenkins_instance_type

  subnet_id              = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata/jenkins.sh")

  root_block_device {

    volume_type           = "gp3"

    volume_size           = var.jenkins_volume_size

    delete_on_termination = true

    encrypted             = true

  }

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

  }

  tags = {

    Name = local.jenkins_name

    Server = "Jenkins"

  }

}

##########################################################
# Web Server EC2
##########################################################

resource "aws_instance" "web" {

  ami                    = data.aws_ami.rhel9.id

  instance_type          = var.web_instance_type

  subnet_id              = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata/webserver.sh")

  root_block_device {

    volume_type           = "gp3"

    volume_size           = var.web_volume_size

    delete_on_termination = true

    encrypted             = true

  }

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

  }

  tags = {

    Name = local.web_name

    Server = "Application"

  }

}
