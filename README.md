# Overview

AWS Security group에 대한 Terraform 모듈입니다. 한 번에, 다수의 Security group과 Rule을 프로비저닝할 수 있는 것을 지향하고 있습니다. 하단의 내용은 `terraform-docs`에 의해 생성되었습니다.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.50.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.25.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_additional_tag"></a> [global\_additional\_tag](#input\_global\_additional\_tag) | Additional tags for all resources. | `map(string)` | `{}` | no |
| <a name="input_name_tag_convention"></a> [name\_tag\_convention](#input\_name\_tag\_convention) | The name tag convention of all resources. | <pre>object({<br>    project_name = string<br>    stage        = string<br>  })</pre> | <pre>{<br>  "project_name": "tf",<br>  "stage": "poc"<br>}</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The security gorup information | <pre>list(object({<br>    identifier       = string<br>    description      = string<br>    name_tag_postfix = string<br>    additional_tag   = optional(map(string))<br>    ingresses = list(object({<br>      description                      = string<br>      from_port                        = string<br>      to_port                          = string<br>      protocol                         = string<br>      cidr_blocks                      = optional(list(string))<br>      ipv6_cidr_blocks                 = optional(list(string))<br>      prefix_list_ids                  = optional(list(string))<br>      source_security_group_identifier = optional(string)<br>      source_security_group_id         = optional(string)<br>      self                             = optional(bool)<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of vpc where you want to place security group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | The dictioanry of the security group id |

## Example
```hcl
vpc_id = ""

security_groups = [
  {
    identifier       = "ec2-bastion"
    name_tag_postfix = "ec2-bastion"
    description      = "the security group for bastion host"
    ingresses = [
      {
        description = "SSH connection"
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["1.2.3.4/32"]
      }
    ]
  },
  {
    identifier       = "elb-web"
    description      = "the security group for prod elb"
    name_tag_postfix = "elb-web"
    ingresses = [
      {
        description = "Web service"
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  },
  {
    identifier       = "ec2-web"
    name_tag_postfix = "ec2-web"
    description      = "the security group for prod elb"
    ingresses = [{
      description                      = "Web service"
      from_port                        = "80"
      to_port                          = "80"
      protocol                         = "tcp"
      source_security_group_identifier = "elb-web"
      }, {
      description                      = "Connect from bastion host"
      from_port                        = "22"
      to_port                          = "22"
      protocol                         = "tcp"
      source_security_group_identifier = "ec2-bastion"
      }, {
      description = "itself"
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      self        = true
      }, {
      description = "itself"
      from_port   = "2222"
      to_port     = "2222"
      protocol    = "tcp"
      self        = true
      }
    ]
  }
]
```
<!-- END_TF_DOCS -->

# Example code

```hcl
provider "aws" {
  region  = "ap-northeast-2"
  profile = "default"
}

module "scg" {
  source              = "../"

  vpc_id              = local.vpc_id
  security_groups     = local.security_groups
  name_tag_convention = local.name_tag_convention
}

data "aws_vpc" "default_vpc" {
  default = true
}

locals {
  name_tag_convention = {
    project_name   = "imys"
    stage          = "prd"
  }

  vpc_id = data.aws_vpc.default_vpc.id

  security_groups = [
    {
      identifier       = "ec2-bastion"
      name_tag_postfix = "ec2-bastion"
      description      = "the security group for bastion host"
      ingresses = [{
        description = "SSH connection"
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["1.2.3.4/32"]
        }
      ]
    },
    {
      identifier       = "elb-web"
      description      = "the security group for prod elb"
      name_tag_postfix = "elb-web"
      ingresses = [{
        description = "Web service"
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
    {
      identifier       = "ec2-web"
      name_tag_postfix = "ec2-web"
      description      = "the security group for prod elb"
      ingresses = [{
        description                      = "Web service"
        from_port                        = "80"
        to_port                          = "80"
        protocol                         = "tcp"
        source_security_group_identifier = "elb-web"
        }, {
        description                      = "Connect from bastion host"
        from_port                        = "22"
        to_port                          = "22"
        protocol                         = "tcp"
        source_security_group_identifier = "ec2-bastion"
        }, {
        description                      = "itself"
        from_port                        = "22"
        to_port                          = "22"
        protocol                         = "tcp"
        self                             = true
        }
      ]
    }
  ]
}
```