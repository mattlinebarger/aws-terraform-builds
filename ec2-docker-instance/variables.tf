variable "ec2-user_password" {
  type        = string
  default     = ""
}
variable "sftp_path" {
  type        = string
  default     = ""
}
variable "profile_name" {
  type        = string
  default     = ""
}
variable "ami" {
  type        = string
  default     = ""
}
variable "region" {
  type        = string
  default     = ""
}
variable "instance_type" {
  type        = string
  default     = ""
}
variable "instance_key" {
  type        = string
  default     = ""
}
variable "vpc" {
  type        = string
  default     = ""
}
variable "subnet" {
  type        = string
  default     = ""
}
variable "security_groups" {
  type        = list(any)
  default     = []
}
variable "instance_tags" {
  type        = map(any)
  default     = {}
}
