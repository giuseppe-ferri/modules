variable "alb_name" {
 description = "The name to use for this ALB"
 type = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type = list(string)
}