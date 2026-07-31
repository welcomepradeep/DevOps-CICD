##########################################################
# Latest RHEL 9 AMI
##########################################################

data "aws_ami" "rhel9" {

  most_recent = true

  owners = ["822547339308"]

  filter {
    name   = "name"
    values = ["RHEL-9.8.0_HVM_GA-20260521-x86_64-0-Hourly2-GP3"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

}
