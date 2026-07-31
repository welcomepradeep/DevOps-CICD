##########################################################
# IAM Role
##########################################################

resource "aws_iam_role" "ec2_role" {

  name = "${local.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

##########################################################
# Instance Profile
##########################################################

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${local.project_name}-instance-profile"

  role = aws_iam_role.ec2_role.name

}

##########################################################
# Amazon SSM
##########################################################

resource "aws_iam_role_policy_attachment" "ssm" {

  role       = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

##########################################################
# CloudWatch
##########################################################

resource "aws_iam_role_policy_attachment" "cloudwatch" {

  role       = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}
