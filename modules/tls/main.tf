# TLS Keys for Flux
resource "tls_private_key" "flux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "flux" {
  private_key_pem = tls_private_key.flux.private_key_pem
} 