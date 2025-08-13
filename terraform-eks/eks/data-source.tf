data "aws_ssm_parameter" "vpc_id" {
  name = "/roboshop/eks/vpc"
}

data "aws_ssm_parameter" "private" {
  name =    "/roboshop/cidr_private"  
}

data "aws_ssm_parameter" "eks_sg" {
  name = "/roboshop/eks_controlplane"  
}

data "aws_ssm_parameter" "node_sg" {
  name = "/roboshop/node_sg"  
}