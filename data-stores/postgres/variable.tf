variable "environment" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "instance_class" {
  type = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "skip_final_snapshot" {
  type = bool
  default = true 
}

variable "backup_retention_period" {
  type = number
  default = 0
}

variable "security_group_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}