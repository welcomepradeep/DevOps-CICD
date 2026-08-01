##########################################################
# AWS Region
##########################################################

variable "aws_region" {

  description = "AWS Region"

  type = string

  default = "ap-south-1"

}

##########################################################
# Key Pair
##########################################################

variable "key_name" {

  description = "AWS EC2 Key Pair"

  type = string

}

##########################################################
# Jenkins Instance
##########################################################

variable "jenkins_instance_type" {

  description = "Jenkins EC2 Instance"

  type = string

  default = "t3.small"

}

##########################################################
# Web Instance
##########################################################

variable "web_instance_type" {

  description = "Web Server Instance"

  type = string

  default = "t3.small"

}

##########################################################
# VPC CIDR
##########################################################

variable "vpc_cidr" {

  default = "10.0.0.0/16"

}

##########################################################
# Public Subnet
##########################################################

variable "public_subnet_cidr" {

  default = "10.0.1.0/24"

}

##########################################################
# Availability Zone
##########################################################

variable "availability_zone" {

  default = "ap-south-1b"

}

##########################################################
# Jenkins Root Volume
##########################################################

variable "jenkins_volume_size" {

  default = 20

}

##########################################################
# Web Volume
##########################################################

variable "web_volume_size" {

  default = 20

}
##########################################################
# AMI ID
##########################################################
variable "ami_id" {
  description = "RHEL 9 AMI ID"
  type        = string
}

