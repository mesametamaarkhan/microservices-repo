variable "aws_region" {
  description = "AWS region where the EC2 instance will be created."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for Docker and MicroK8s."
  type        = string
  default     = "t3.medium"
}

variable "instance_name" {
  description = "Tag name for the EC2 instance."
  type        = string
  default     = "microservices-server"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name used for SSH."
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to the server."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_app_cidrs" {
  description = "CIDR blocks allowed to access the app NodePorts."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
