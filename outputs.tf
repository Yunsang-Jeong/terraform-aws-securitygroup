output "security_group_id_map" {
  description = "The map of the security group id."
  value = {
    for identifier, scg in aws_security_group.this :
    identifier => scg.id
  }
}
