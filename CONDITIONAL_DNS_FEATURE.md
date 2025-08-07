# Conditional DNS Feature

## Overview
This feature adds flexibility to the Vault Enterprise deployment by making DNS configuration optional. Users can now choose between:
1. **Route53 managed DNS** (default) - with Let's Encrypt SSL certificates
2. **AWS LoadBalancer hostname** - direct access without DNS management overhead

## Configuration Variable

### `use_route53_dns`
- **Type**: `bool`
- **Default**: `true` 
- **Location**: `terraform.auto.tfvars`
- **Description**: Controls whether to use Route53 managed DNS or AWS LoadBalancer hostname

## Behavior Comparison

### Route53 Mode (`use_route53_dns = true`)
**DNS & Certificates:**
- Creates Route53 CNAME record pointing to LoadBalancer
- Generates Let's Encrypt SSL certificate via cert-manager
- Uses custom hostname: `vault.{route53_sandbox_prefix}.sbx.hashidemos.io`

**Kubernetes Ingress:**
- Specific host rule: `vault.david-joo.sbx.hashidemos.io`
- TLS termination with Let's Encrypt certificate
- cert-manager annotations for automatic certificate management

**Access:**
```bash
https://vault.david-joo.sbx.hashidemos.io
```

### LoadBalancer Mode (`use_route53_dns = false`)
**DNS & Certificates:**
- No Route53 record creation
- No Let's Encrypt certificate generation  
- Uses AWS LoadBalancer hostname directly

**Kubernetes Ingress:**
- Catch-all host rule (accepts any hostname)
- No TLS termination (HTTP only)
- No cert-manager annotations

**Access:**
```bash
http://<LoadBalancer-hostname>
# Example: http://a1b2c3d4e5f6g7h8-1234567890.ap-southeast-2.elb.amazonaws.com
```

## Implementation Details

### Key Files Modified
```
terraform.auto.tfvars     # Configuration variable
variables.tf              # Variable definition  
main.tf                   # Pass variable to vault module
03-solution/k8s/vault/
├── dns.tf                # Conditional hostname logic
├── ingress.tf            # Conditional TLS and host configuration  
├── outputs.tf            # Dynamic hostname outputs
├── helm.tf               # Conditional Let's Encrypt issuer email
├── tls.tf                # Conditional certificate subjects
└── variables.tf          # Module variable definition
```

### Conditional Logic Patterns

**DNS Configuration:**
```hcl
locals {
  route53_hostname = "vault.${var.route53_sandbox_prefix}.sbx.hashidemos.io"
  vault_hostname = var.use_route53_dns ? local.route53_hostname : "vault-${var.deployment_id}"
}

# Route53 record only created when enabled
resource "aws_route53_record" "vault" {
  count = var.use_route53_dns ? 1 : 0
  # ... configuration
}
```

**Ingress Configuration:**
```hcl
# Conditional annotations using merge()
annotations = merge(
  {
    "kubernetes.io/ingress.class" = "nginx"
    "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    # ... base annotations
  },
  var.use_route53_dns ? {
    "cert-manager.io/cluster-issuer" = var.use_letsencrypt_prod ? "letsencrypt-prod" : "letsencrypt-staging"
  } : {}
)

# Conditional TLS block using dynamic
dynamic "tls" {
  for_each = var.use_route53_dns ? [1] : []
  content {
    hosts       = [local.route53_hostname]
    secret_name = "vault-tls-cert"
  }
}

# Conditional host rule
rule {
  host = var.use_route53_dns ? local.route53_hostname : null
  # ... http configuration
}
```

## Terraform Plan Validation

### Route53 Mode Plan Results
```bash
terraform plan -target=module.solution-k8s-vault-ent
# Shows:
# + aws_route53_record.vault 
# + cert-manager annotations in ingress
# + TLS block with specific hostname
# + Let's Encrypt cluster issuers
```

### LoadBalancer Mode Plan Results  
```bash
terraform plan -target=module.solution-k8s-vault-ent
# Shows:
# - No aws_route53_record.vault resource
# - No cert-manager annotations  
# - No TLS block in ingress
# + data.kubernetes_service.nginx_ingress_for_output for hostname lookup
```

## Usage Examples

### Standard Deployment (Route53 + SSL)
```hcl
# terraform.auto.tfvars
use_route53_dns = true
```

### Simplified Deployment (LoadBalancer only)
```hcl
# terraform.auto.tfvars
use_route53_dns = false
```

## Outputs

The module provides different outputs based on the DNS mode:

**Route53 Mode:**
```
vault_hostname = "vault.david-joo.sbx.hashidemos.io"
vault_url = "https://vault.david-joo.sbx.hashidemos.io"
vault_ui_fqdn = "vault.david-joo.sbx.hashidemos.io"
actual_loadbalancer_hostname = null
```

**LoadBalancer Mode:**
```
vault_hostname = "Use the LoadBalancer hostname shown below"
vault_url = "Use https://<LoadBalancer_hostname> shown below"  
vault_ui_fqdn = "a1b2c3-123456789.ap-southeast-2.elb.amazonaws.com"
actual_loadbalancer_hostname = "a1b2c3-123456789.ap-southeast-2.elb.amazonaws.com"
```

## Benefits

### Route53 Mode Benefits
- Custom branded hostname
- Automatic SSL certificate management
- Production-ready HTTPS access
- Certificate auto-renewal

### LoadBalancer Mode Benefits
- No DNS management required
- Faster deployment (no Route53 dependencies)
- Simplified networking
- Lower cost (no Route53 hosted zone charges)

## Git Branch Management

This feature is developed in the `feature/conditional-dns-setup` branch:

```bash
git checkout feature/conditional-dns-setup  # Switch to feature branch
git checkout main                          # Switch back to stable main
```

## Testing Status

- ✅ Terraform plan validation (both modes)
- ✅ Syntax validation
- ✅ Conditional logic testing
- ✅ Output validation
- ⏳ Full deployment testing (pending)
- ⏳ End-to-end access testing (pending)

## Next Steps

1. Full deployment testing with both modes
2. Validation of actual LoadBalancer hostname access
3. Documentation update in main README.md
4. Merge feature branch to main after validation
