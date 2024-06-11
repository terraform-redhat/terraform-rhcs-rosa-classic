output "trusted_ip_addresses" {
  description = "Trusted Ip Addresses"
  value       = data.rhcs_trusted_ip_addresses.all
}