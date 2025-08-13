locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnet = split(",",data.aws_ssm_parameter.private.value)
  eks_sg = data.aws_ssm_parameter.eks_sg.value
  node_sg = data.aws_ssm_parameter.node_sg.value
}
   