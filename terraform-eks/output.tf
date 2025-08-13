# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

## to check the availability zones in a VPC
output "availability_zone" {
  value = data.aws_availability_zones.available.names
}

output "public_subnet" {
 value = aws_subnet.public[*].id 
}
