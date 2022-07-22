# Variables

#variable "aws_access_key" {
#  type = string
#}

#variable "aws_secret_key" {
#  type = string
#}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = string
  default = "172.16.0.0/16"
}

variable "ssh_default_port" {
  type = string
  default = 22
}

variable "ssh_public_key" {
  type = string
}
variable "jenkins_default_port" {
  type = string
  default = 8080
}
