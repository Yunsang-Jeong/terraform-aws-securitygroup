provider "aws" {
  default_tags {
    tags = {
      TerraformModuleTest = "complex"
    }
  }
}

run "get_default_vpc_id" {
  module {
    source = "./tests/get_default_vpc_id"
  }
}

run "default" {
  variables {
    vpc_id = run.get_default_vpc_id.default_vpc_id
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

  assert {
    condition     = length(var.security_groups) == length(output.security_group_ids)
    error_message = "need to check `aws_security_group` block."
  }

  assert {
    condition = alltrue([
      for sg in var.security_groups :
      length(sg.ingresses) == (
        length([
          for ingress in keys(aws_security_group_rule.ingress) :
          ingress
          if startswith(ingress, sg.identifier)
        ])
        +
        length([
          for ingress in keys(aws_security_group_rule.ingress_with_cidr_blocks) :
          ingress
          if startswith(ingress, sg.identifier)
        ])
        +
        length([
          for ingress in keys(aws_security_group_rule.ingress_with_ipv6_cidr_blocks) :
          ingress
          if startswith(ingress, sg.identifier)
        ])
        +
        length([
          for ingress in keys(aws_security_group_rule.ingress_with_prefix_list_ids) :
          ingress
          if startswith(ingress, sg.identifier)
        ])
      )
    ])
    error_message = "need to check ingress-rules."
  }

  assert {
    condition = alltrue([
      for sg in var.security_groups :
      length(sg.egresses) == (
        length([
          for egress in keys(aws_security_group_rule.egress) :
          egress
          if startswith(egress, sg.identifier)
        ])
        +
        length([
          for egress in keys(aws_security_group_rule.egress_with_cidr_blocks) :
          egress
          if startswith(egress, sg.identifier)
        ])
        +
        length([
          for egress in keys(aws_security_group_rule.egress_with_ipv6_cidr_blocks) :
          egress
          if startswith(egress, sg.identifier)
        ])
        +
        length([
          for egress in keys(aws_security_group_rule.egress_with_prefix_list_ids) :
          egress
          if startswith(egress, sg.identifier)
        ])
      )
    ])
    error_message = "need to check egress-rules."
  }
}