#--------------------------------------------------
# Elastic Container Registry (ECR) Repository
#--------------------------------------------------
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  tags                 = var.tags

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  dynamic "image_scanning_configuration" {
    for_each = try(var.image_scanning_configuration, null) != null ? [var.image_scanning_configuration] : []
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }
}

#--------------------------------------------------
# Elastic Container Registry (ECR) Repository Policy
#--------------------------------------------------
resource "aws_ecr_repository_policy" "this" {
  count = var.repository_policy != "" ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy
}

#--------------------------------------------------
# Elastic Container Registry (ECR) Lifecycle Policy
#--------------------------------------------------
resource "aws_ecr_lifecycle_policy" "this" {
  count = var.lifecycle_policy != "" ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy
}

#--------------------------------------------------
# Elastic Container Registry (ECR) Cross-Region
# Replication Configuration
#
# NOTE: This is a registry-level singleton resource.
# Set create_replication_config=true in ONLY ONE module
# instance per AWS account. All other instances must set
# it to false to avoid Terraform conflicts.
#--------------------------------------------------
resource "aws_ecr_replication_configuration" "this" {
  count = var.create_replication_config ? 1 : 0

  replication_configuration {
    dynamic "rule" {
      for_each = var.cross_region_replication_rules
      content {
        destination {
          region      = rule.value.destination_region
          registry_id = rule.value.destination_registry_id
        }

        dynamic "repository_filter" {
          # Only add a filter block when replicate_all_repositories is false.
          # Coalescing null to empty string keeps the conditional boolean-safe.
          for_each = !rule.value.replicate_all_repositories ? [1] : []
          content {
            filter      = coalesce(rule.value.repository_filter_value, "")
            filter_type = coalesce(rule.value.repository_filter_type, "PREFIX_MATCH")
          }
        }
      }
    }
  }
}
