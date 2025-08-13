resource "aws_ssm_parameter" "vpc_id" {
  value = aws_vpc.main.id
  type = "String"
  name = "/roboshop/eks/vpc"
}

resource "aws_ssm_parameter" "cidr_public" {
  value = join(",",aws_subnet.public[*].id)
  type = "StringList"
  name = "/roboshop/cidr_public"  
}

resource "aws_ssm_parameter" "cidr_private" {
  value = join("," , aws_subnet.private[*].id)
  type = "StringList"
  name = "/roboshop/cidr_private"  
}

resource "aws_ssm_parameter" "eks_control_plane_sg" {
  value = aws_security_group.eks_control_plane.id
  type = "StringList"
  name = "/roboshop/eks_controlplane"  
}

resource "aws_ssm_parameter" "node_sg" {
  value = aws_security_group.nodes.id
  type = "StringList"
  name = "/roboshop/node_sg"  
}

data "aws_ami" "name" {

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}