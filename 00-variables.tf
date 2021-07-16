########################################
# Shared
variable "name_tag_convention" {
  description = "The name tag convention of all resources."
  type = object({
    project_name = string
    stage        = string
  })
  default = {
    project_name = "tf"
    stage        = "poc"
  }
}

variable "global_additional_tag" {
  description = "Additional tags for all resources."
  type        = map(string)
  default     = {}
}
########################################


########################################
# VPC ID
variable "vpc_id" {
  description = "The id of vpc where you want to place security group"
  type        = string
}
########################################


########################################
# Security groups
variable "security_groups" {
  description = "The security gorup information"
  type = list(object({
    identifier       = string
    description      = string
    name_tag_postfix = string
    additional_tag   = optional(map(string))
    ingresses = list(object({
      description                      = string
      from_port                        = string
      to_port                          = string
      protocol                         = string
      cidr_blocks                      = optional(list(string))
      ipv6_cidr_blocks                 = optional(list(string))
      prefix_list_ids                  = optional(list(string))
      source_security_group_identifier = optional(string)
      source_security_group_id         = optional(string)
      self                             = optional(bool)
    }))
  }))
}
########################################