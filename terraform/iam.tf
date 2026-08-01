##########################################################
# Existing IAM Instance Profile
##########################################################

data "aws_iam_instance_profile" "ec2_profile" {

  name = "TerraformRole"

}
