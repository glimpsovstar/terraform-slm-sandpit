# Quick Deployment Reference

This is a condensed version of the full deployment guide for quick reference.

## Commands Summary

### Stage 1: AWS Infrastructure
```bash
terraform apply -target=module.infra-aws -auto-approve
```

### Stage 2: EKS Platform  
```bash
terraform apply -target=module.platform-k8s-eks -auto-approve
```

### Stage 3: Vault Solution
```bash
terraform apply -auto-approve
```

## Post-Deployment Steps

### 1. Wait for LoadBalancer
```bash
kubectl get service -n ingress-nginx ingress-nginx-controller --watch
```

### 2. Initialize Vault
```bash
kubectl exec -it vault-0 -n vault -- vault operator init -format=json
```

### 3. Verify Access
- URL: https://vault.david-joo.sbx.hashidemos.io:8200
- Health: `curl -s https://vault.david-joo.sbx.hashidemos.io/v1/sys/health`

## Troubleshooting Commands

### Check Certificate Status
```bash
kubectl get certificates -n vault
kubectl describe certificate vault-tls-cert -n vault
```

### Check DNS Resolution
```bash
nslookup vault.david-joo.sbx.hashidemos.io
```

### Check Vault Status
```bash
kubectl get pods -n vault
kubectl logs vault-0 -n vault
```

## Cleanup Commands
```bash
terraform destroy -target=module.solution-k8s-vault-ent -auto-approve
terraform destroy -target=module.platform-k8s-eks -auto-approve  
terraform destroy -target=module.infra-aws -auto-approve
terraform destroy -auto-approve
```

## Key Lessons

1. **Multi-stage deployment is essential** for complex infrastructure
2. **Wait for dependencies** - LoadBalancer, DNS propagation, certificate provisioning
3. **KMS auto-unseal** eliminates unseal key management
4. **Proper SSL proxy settings** are critical for NGINX ingress with HTTPS backends
5. **Test each stage** before proceeding to the next

## Success Indicators

- ✅ All Vault pods running (3/3)
- ✅ Certificate status: Ready
- ✅ DNS resolves to LoadBalancer  
- ✅ HTTPS endpoint returns valid JSON
- ✅ Vault status shows unsealed and initialized
