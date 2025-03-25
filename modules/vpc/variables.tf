variable "prefix" {}
variable "env" {}
variable "vpc_cidr" {}
variable "req_subnet_num" {}
variable "availability_zones" {
  type = list(string)
  default = [
    "1d",
    "1c",
    "1a"
  ]
}