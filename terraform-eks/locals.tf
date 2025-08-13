locals {
  availability_zone = data.aws_availability_zones.available.names
  public_subnet = aws_subnet.public[0].id
}