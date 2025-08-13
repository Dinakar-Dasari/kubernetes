variable "cidr_public" {
  type = list
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "cidr_private" {
  type = list
  default = ["10.0.3.0/24","10.0.4.0/24"]
}

variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "aws_zone_id" {
  default = "Z02485381IKGKKF8Y47H9"
}

variable "aws_zone_name" {
  default = "jiony.xyz"
}