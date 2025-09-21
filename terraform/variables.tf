variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair"
  default     = "terraform-key"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instance access"
  type        = string
  sensitive = true
}
