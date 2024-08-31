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
