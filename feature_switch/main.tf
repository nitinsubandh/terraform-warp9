provider "aws" {
    region = "us-east-1"
}

variable "environment" {
    type = string
}
variable "type" {
    type = string
    default = "t2.micro"
}
resource "aws_instance" "ec2" {
    ami = "ami-032598fcc7e9d1c7a"
    instance_type = var.type
    count = var.environment == "prod" ? 1 : 0
}