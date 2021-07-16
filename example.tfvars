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