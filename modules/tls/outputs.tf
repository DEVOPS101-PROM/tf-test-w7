output "private_key" {
  description = "Private key for Flux SSH authentication"
  value       = tls_private_key.flux.private_key_pem
  sensitive   = true
}

output "public_key" {
  description = "Public key for Flux SSH authentication"
  value       = data.tls_public_key.flux.public_key_pem
} 