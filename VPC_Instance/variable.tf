variable "cidr" {
  default = "10.0.0.0/16"
}

variable "aws_ami" {
    description = "ami name"
    type = string
  
}

variable "aws_instance" {
    description = "EC2 instance"
    type = string
    default = "t2.micro"
  
}