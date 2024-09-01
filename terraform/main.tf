terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "airbnb"
}

# S3 bucket with lifecycle config
resource "aws_s3_bucket" "data-lake-bucket" {
  bucket = var.s3-bucket
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-lifecycle" {
  bucket = aws_s3_bucket.data-lake-bucket.id

  rule {
    id = "Expiry rule"

    expiration {
      days = 90
    }

    filter {
      prefix = "raw/"
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

# aws-ia MWAA environment

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
  bucket_name = format("%s-%s", "aws-ia-mwaa", data.aws_caller_identity.current.account_id)
}


module "mwaa" {
  source  = "aws-ia/mwaa/aws"
  version = "0.0.6"

  name              = var.name
  airflow_version   = "2.9.2"
  environment_class = "mw1.small"
  create_s3_bucket  = false
  source_bucket_arn = aws_s3_bucket.data-lake-bucket.arn

  min_workers           = 1
  max_workers           = 2
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  webserver_access_mode = "PUBLIC_ONLY" # Default PRIVATE_ONLY for production environments
  source_cidr           = ["10.1.0.0/16"]

  logging_configuration = {
    dag_processing_logs = {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs = {
      enabled   = true
      log_level = "INFO"
    }

    task_logs = {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs = {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs = {
      enabled   = true
      log_level = "INFO"
    }
  }

  airflow_configuration_options = {
    "core.load_default_connections" = "false"
    "core.load_examples"            = "false"
    "webserver.dag_default_view"    = "tree"
    "webserver.dag_orientation"     = "TB"
    "logging.logging_level"         = "INFO"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

}
