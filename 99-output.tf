output "security_group_ids" {
  description = "The dictioanry of the security group id"
  value       = { for identifier, scg in aws_security_group.this : identifier => scg.id }
}