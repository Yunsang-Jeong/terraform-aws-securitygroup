################################################################################
# Common

variable "name_prefix" {
  description = "The name-prefix of all resources."
  type        = string
  default     = "tf-poc"
}

variable "global_additional_tag" {
  description = "Additional tags for all resources."
  type        = map(string)
  default = {
    "TerraformModuleSource" = "github.com/Yunsang-Jeong/terraform-aws-securitygroup"
  }
}
################################################################################


################################################################################
# VPC ID

variable "vpc_id" {
  description = "The id of vpc where you want to place security group"
  type        = string
}
################################################################################


################################################################################
# Security groups

variable "security_groups" {
  description = "The security gorup information"
  type = list(object({
    identifier     = string
    description    = string
    additional_tag = optional(map(string), {})
    ingresses = optional(list(object({
      identifier                       = string
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
    })), [])
    egresses = optional(list(object({
      identifier                            = string
      description                           = string
      from_port                             = string
      to_port                               = string
      protocol                              = string
      cidr_blocks                           = optional(list(string))
      ipv6_cidr_blocks                      = optional(list(string))
      prefix_list_ids                       = optional(list(string))
      destination_security_group_identifier = optional(string)
      destination_security_group_id         = optional(string)
      self                                  = optional(bool)
      })), [
      {
        identifier  = "default"
        description = "Default"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ])
  }))
  default = []
}
################################################################################
