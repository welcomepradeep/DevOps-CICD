##########################################################
# Jenkins Outputs
##########################################################

output "jenkins_instance_id" {

  value = aws_instance.jenkins.id

}

output "jenkins_public_ip" {

  value = aws_instance.jenkins.public_ip

}

output "jenkins_public_dns" {

  value = aws_instance.jenkins.public_dns

}

##########################################################
# Web Outputs
##########################################################

output "web_instance_id" {

  value = aws_instance.web.id

}

output "web_public_ip" {

  value = aws_instance.web.public_ip

}

output "web_public_dns" {

  value = aws_instance.web.public_dns

}

##########################################################
# VPC Outputs
##########################################################

output "vpc_id" {

  value = aws_vpc.main.id

}

output "public_subnet_id" {

  value = aws_subnet.public.id

}
