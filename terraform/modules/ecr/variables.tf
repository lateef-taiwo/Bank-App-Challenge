variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "tags" {
  description = "Tags to apply to the repository"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for ECR encryption. Leave null to let AWS manage the key."
  type        = string
  default     = null
}

variable "image_scanning_configuration" {
  description = "Image scanning configuration block. Set to null to disable."
  type = object({
    scan_on_push = bool
  })
  default = {
    scan_on_push = true
  }
}

variable "repository_policy" {
  description = "JSON repository policy. Leave empty string to skip."
  type        = string
  default     = ""
}

variable "lifecycle_policy" {
  description = "JSON lifecycle policy. Leave empty string to skip."
  type        = string
  default     = ""
}

#--------------------------------------------------
# Cross-region replication variables
#
# create_replication_config must be true on ONLY ONE
# module instance per AWS account (registry singleton).
#
# cross_region_replication_rules accepts a list of
# objects. Each object = one replication rule.
# To replicate specific repos, set:
#   replicate_all_repositories = false
#   repository_filter_value    = "repo-name-prefix"
#   repository_filter_type     = "PREFIX_MATCH"
#
# To replicate ALL repos in the registry, set:
#   replicate_all_repositories = true
#   (repository_filter_value and type are ignored)
#--------------------------------------------------
variable "create_replication_config" {
  description = "Whether to create the registry-level replication config. Only set true on ONE module instance per account."
  type        = bool
  default     = false
}

variable "cross_region_replication_rules" {
  description = <<-EOT
    List of cross-region replication rules. Each rule targets one destination
    region/registry and optionally filters by repository prefix.

    Example — replicate two specific repos to us-east-2:
    [
      {
        destination_region         = "us-east-2"
        destination_registry_id    = "123456789012"
        replicate_all_repositories = false
        repository_filter_value    = "my-app"
        repository_filter_type     = "PREFIX_MATCH"
      }
    ]
  EOT
  type = list(object({
    destination_region         = string
    destination_registry_id    = string
    replicate_all_repositories = bool
    repository_filter_value    = string
    repository_filter_type     = string
  }))
  default = []
}
