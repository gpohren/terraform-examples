output "elb-dns" {
  description = "DNS name"
  value       = aws_elb.elb1.dns_name
}