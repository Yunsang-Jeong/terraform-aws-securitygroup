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
