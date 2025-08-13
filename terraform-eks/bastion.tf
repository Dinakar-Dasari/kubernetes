resource "aws_instance" "bastion" {
  ami           = data.aws_ami.name.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id = local.public_subnet

  # need more for terraform
  root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
  }
  user_data = file("bastion.sh")
  # iam_instance_profile = "TerraformAdmin"
}