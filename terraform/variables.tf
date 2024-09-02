variable "s3_bucket" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "airbnb-analytics-bucket"
}

variable "redshift_cluster" {
  description = "Name of Redshift Cluster"
  type        = string
  default     = "airbnb-data-warehouse"
}

variable "rs_db_name" {
  description = "Name of Redshift Database"
  type        = string
  default     = "airbnb_db"
}

variable "rs_master_username" {
  description = "Master username for Redshift"
  type        = string
}

variable "rs_master_password" {
  description = "Master password for Redshift"
  type        = string
}

variable "rs_vpc_cidr" {
  description = "VPC CIDR for Redshift"
  type        = string
  default     = "10.0.0.0/16"
}

variable "mwaa_name" {
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
