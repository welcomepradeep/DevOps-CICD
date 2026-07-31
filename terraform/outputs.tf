##########################################################
# Jenkins Public IP
##########################################################

output "jenkins_public_ip" {

  description = "Public IP of Jenkins Server"

  value = aws_instance.jenkins.public_ip

}

##########################################################
# Web Server Public IP
##########################################################

output "web_public_ip" {

  description = "Public IP of Web Server"

  value = aws_instance.web.public_ip

}

##########################################################
# Jenkins Public DNS
##########################################################

output "jenkins_public_dns" {

  value = aws_instance.jenkins.public_dns

}

##########################################################
# Web Server Public DNS
##########################################################

output "web_public_dns" {

  value = aws_instance.web.public_dns

}
