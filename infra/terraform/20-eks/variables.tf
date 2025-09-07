variable "project" { type = string }
variable "cluster_version" {
  type    = string
  default = "1.29"
}
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "vpc_id" { type = string }
