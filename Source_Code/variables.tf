# AWS Regions

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_west_region" {
  description = "Secondary AWS region"
  type        = string
  default     = "us-west-2"
}

# Instance Type

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.micro"], var.instance_type)
    error_message = "The instance type must be t2.micro, t2.small, or t3.micro."
  }
}

# S3 Bucket Names

variable "terraform_state_bucket" {
  description = "S3 bucket name for storing Terraform state"
  type        = string
  default     = "aws-tf-backend-vv-bucket"
}

variable "backup_bucket" {
  description = "S3 bucket name for backups"
  type        = string
  default     = "terra-backup-vv-project-bucket"
}

# ALB Names

variable "primary_alb_name" {
  description = "Name of the primary ALB"
  type        = string
  default     = "primary-alb"
}

variable "secondary_alb_name" {
  description = "Name of the secondary ALB"
  type        = string
  default     = "secondary-alb"
}

# Route 53 Zone Domain

variable "route53_zone_domain" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
  default     = "myinfra.local"
}

# Notification Email for SNS

variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = "vivekvash1507@gmail.com"
  validation {
    condition     = length(regexall("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email)) > 0
    error_message = "The email format is invalid."
  }
}