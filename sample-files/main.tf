# Terraform sample: providers, resources, variables, locals, expressions.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket = "shibbir-terraform-state"
    key    = "themes/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be one of dev, staging, production."
  }
}

variable "swatches" {
  description = "Theme colors to publish as parameters"
  type = map(object({
    hex        = string
    font_style = optional(string, "normal")
  }))

  default = {
    background = { hex = "#263238" }
    foreground = { hex = "#EEFFFF" }
    keyword    = { hex = "#C792EA" }
    comment    = { hex = "#546E7A", font_style = "italic" }
  }
}

locals {
  name_prefix = "themes-of-shibbir-${var.environment}"

  common_tags = {
    Project     = "themes-of-shibbir"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "shibbir"
  }

  italic_swatches = {
    for key, value in var.swatches : key => value
    if value.font_style == "italic"
  }

  hex_list = [for key, value in var.swatches : upper(value.hex)]
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.name_prefix}-${random_id.suffix.hex}"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-artifacts"
  })
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = var.environment == "production" ? "Enabled" : "Suspended"
  }
}

resource "aws_ssm_parameter" "swatch" {
  for_each = var.swatches

  name  = "/${local.name_prefix}/colors/${each.key}"
  type  = "String"
  value = each.value.hex

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags["LastModified"]]
  }
}

data "aws_caller_identity" "current" {}

output "bucket_name" {
  description = "Name of the artifacts bucket"
  value       = aws_s3_bucket.artifacts.bucket
}

output "account_id" {
  description = "AWS account the stack is deployed into"
  value       = data.aws_caller_identity.current.account_id
  sensitive   = true
}

output "italic_count" {
  description = "How many swatches render italic"
  value       = length(local.italic_swatches)
}
