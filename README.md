# Overview

Terraform module for AWS Security group, which aims to focus on actual service operations.



The module has the following characteristics:

- You can provision multiple security groups and rules at one time.
- Individual `identifier`  are entered into each security group, ingress, and egress rule to apply `lifecycle { create_before_destroy = true}`.
- There is a caution when using `cidr_blocks`, `ipv6_cidr_blocks`, and `prefix_list_ids` in `aws_security_group_rule`. 
  If there is a change in `cidr_blocks`, the `aws_security_group_rule` itself is replaced (delete and create), not just the changed part. This can cause an issue in service operation. Therefore, `aws_security_group_rule` is created by separating the items of `cidr_block` individually (This is the same for `ipv6_cidr_blocks` and `prefix_list_ids`.).



If `var.security_groups` is too long, please consider writing it in yaml or json file and using `yamldcode()` or `jsondecode()`.



The contents below are generated by `terrform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_additional_tag"></a> [global\_additional\_tag](#input\_global\_additional\_tag) | Additional tags for all resources. | `map(string)` | <pre>{<br>  "TerraformModuleSource": "github.com/Yunsang-Jeong/terraform-aws-securitygroup"<br>}</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name-prefix of all resources. | `string` | `"tf-poc"` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The security gorup information | <pre>list(object({<br>    identifier     = string<br>    description    = string<br>    additional_tag = optional(map(string), {})<br>    ingresses = optional(list(object({<br>      identifier                       = string<br>      description                      = string<br>      from_port                        = string<br>      to_port                          = string<br>      protocol                         = string<br>      cidr_blocks                      = optional(list(string))<br>      ipv6_cidr_blocks                 = optional(list(string))<br>      prefix_list_ids                  = optional(list(string))<br>      source_security_group_identifier = optional(string)<br>      source_security_group_id         = optional(string)<br>      self                             = optional(bool)<br>    })), [])<br>    egresses = optional(list(object({<br>      identifier                            = string<br>      description                           = string<br>      from_port                             = string<br>      to_port                               = string<br>      protocol                              = string<br>      cidr_blocks                           = optional(list(string))<br>      ipv6_cidr_blocks                      = optional(list(string))<br>      prefix_list_ids                       = optional(list(string))<br>      destination_security_group_identifier = optional(string)<br>      destination_security_group_id         = optional(string)<br>      self                                  = optional(bool)<br>      })), [<br>      {<br>        identifier  = "default"<br>        description = "Default"<br>        from_port   = 0<br>        to_port     = 0<br>        protocol    = "-1"<br>        cidr_blocks = ["0.0.0.0/0"]<br>      }<br>    ])<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of vpc where you want to place security group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | The map of the security group id. |

## Example
```terraform
module "security_group" {
  source = "github.com/Yunsang-Jeong/terraform-aws-securitygroup"
  
  vpc_id = "vpc-000000000000"
  security_groups = [
    {
      identifier  = "ec2-bastion"
      description = "the security group for bastion host"
      ingresses = [
        {
          identifier  = "ssh-public"
          description = "SSH connection"
          from_port   = "22"
          to_port     = "22"
          protocol    = "tcp"
          cidr_blocks = ["1.2.3.4/32"]
        }
      ]
    },
    {
      identifier  = "elb-web"
      description = "the security group for web-elb"
      ingresses = [
        {
          identifier  = "web"
          description = "Web service"
          from_port   = "443"
          to_port     = "443"
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egresses = [
        {
          identifier                            = "health-check-to-web"
          description                           = "Health check"
          from_port                             = "80"
          to_port                               = "80"
          protocol                              = "tcp"
          destination_security_group_identifier = "ec2-web"
      }]
    },
    {
      identifier  = "ec2-web"
      description = "the security group for web-elb"
      ingresses = [
        {
          identifier                       = "srv-web-elb"
          description                      = "Connection from elb"
          from_port                        = "80"
          to_port                          = "80"
          protocol                         = "tcp"
          source_security_group_identifier = "elb-web"
          }, {
          identifier                       = "ssh-from-bastion"
          description                      = "Connection from bastion"
          from_port                        = "22"
          to_port                          = "22"
          protocol                         = "tcp"
          source_security_group_identifier = "ec2-bastion"
        }
      ]
    },
    {
      identifier  = "vpc-endpoint"
      description = "the security group for vpc-endpoint"
      ingresses = [
        {
          identifier  = "https-itself"
          description = "itself"
          from_port   = "443"
          to_port     = "443"
          protocol    = "tcp"
          self        = true
        }
      ]
    }
  ]
}
```
<!-- END_TF_DOCS -->
