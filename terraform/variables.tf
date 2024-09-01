variable "s3-bucket" {
  default = "airbnb-analytics-bucket"
}

variable "name" {
  description = "Name of MWAA Environment"
  default     = "airbnb-mwaa"
  type        = string
}

variable "region" {
  description = "region"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR for MWAA"
  type        = string
  default     = "10.1.0.0/16"
}
