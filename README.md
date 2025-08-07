# HashiCorp Vault Enterprise on AWS EKS - Production Deployment Guide

This repository contains Terraform infrastructure as code for deploying a production-ready HashiCorp Vault Enterprise cluster on AWS EKS with SSL certificates and high availability.

## Architecture Overview

- **AWS Infrastructure**: VPC with 6 subnets across 3 AZs, NAT Gateway, security groups
- **EKS Cluster**: Kubernetes 1.32 with managed node groups
- **Vault Enterprise**: 3-replica HA cluster with Raft storage and AWS KMS auto-unseal
- **SSL/TLS**: Let's Encrypt certificates with automated renewal via cert-manager
- **Ingress**: NGINX Ingress Controller with proper SSL termination

## Prerequisites

- AWS CLI configured with appropriate permissions
- kubectl installed
- Terraform >= 1.0
- Valid HashiCorp Vault Enterprise license
- Route53 hosted zone (for SSL certificate validation)

## Step-by-Step Deployment Process

### Why Multi-Stage Deployment?

During development, we discovered that a single `terraform apply` approach led to dependency issues and timing problems. The multi-stage approach ensures:

1. **Infrastructure Foundation**: AWS resources must exist before EKS can be deployed
2. **Platform Readiness**: EKS cluster must be running before Kubernetes resources can be created
3. **SSL Dependencies**: LoadBalancer must have an external IP before Route53 DNS records can be created

### Stage 1: AWS Infrastructure

Deploy the foundational AWS resources including VPC, subnets, security groups, KMS keys, and bastion host.

```bash
terraform apply -target=module.infra-aws -auto-approve
```

**Expected Output:**

- New VPC created (CIDR: 10.200.0.0/16)
- 6 subnets across 3 availability zones
- Security groups for SSH and Vault access  
- KMS key for Vault auto-unseal
- Bastion host for cluster access
- Key pair for EC2 access

**Verification:**

```bash
# Check VPC creation
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*djoo*" --query 'Vpcs[*].{VpcId:VpcId,CidrBlock:CidrBlock,State:State}'

# Verify KMS key
aws kms list-aliases --query 'Aliases[?contains(AliasName, `djoo`) && contains(AliasName, `vault`)]'
```

### Stage 2: EKS Platform

Deploy the EKS cluster and configure Kubernetes access.

```bash
terraform apply -target=module.platform-k8s-eks -auto-approve
```

**Expected Output:**

- EKS cluster with Kubernetes 1.32
- 3-node managed node group (m7i.large instances)
- AWS EBS CSI driver addon
- OIDC provider for service account roles
- Updated kubeconfig automatically

**Verification:**

```bash
# Check cluster status
kubectl get nodes

# Verify EKS addons
aws eks describe-addon --cluster-name <cluster-name> --addon-name aws-ebs-csi-driver

# Test cluster connectivity
kubectl get namespaces
```

**Common Issues & Solutions:**

- **Node group creation timeout**: EKS managed node groups can take 10-15 minutes to provision
- **OIDC provider issues**: Ensure proper IAM permissions for EKS service role

### Stage 3: Complete Vault Deployment

Deploy the full Vault solution with SSL certificates and ingress.

```bash
terraform apply -auto-approve
```

**Expected Components:**
- NGINX Ingress Controller with AWS LoadBalancer
- cert-manager for SSL certificate management
- Let's Encrypt ClusterIssuers (staging and production)
- Vault Enterprise helm deployment
- Route53 DNS record pointing to LoadBalancer
- SSL certificate automatically provisioned

**Critical Timing Issues Encountered:**

1. **LoadBalancer Provisioning Delay**: The AWS LoadBalancer takes 2-3 minutes to provision and get an external hostname. If Terraform tries to create Route53 records before this, it fails.

   **Solution**: We implemented a retry mechanism and verified LoadBalancer status:
   ```bash
   kubectl get service -n ingress-nginx ingress-nginx-controller
   # Wait until EXTERNAL-IP shows LoadBalancer hostname
   ```

2. **DNS Propagation**: Route53 records need time to propagate before Let's Encrypt can validate domain ownership.

   **Solution**: Added verification step:
   ```bash
   nslookup vault.david-joo.sbx.hashidemos.io
   ```

### Post-Deployment Configuration

#### Initialize Vault

Since we're using AWS KMS auto-unseal, initialization is simpler:

```bash
# Initialize Vault (no unseal keys needed with KMS)
kubectl exec -it vault-0 -n vault -- vault operator init -format=json
```

**Save the output securely** - you'll need the root token and recovery keys.

#### Verify SSL Certificate

```bash
# Check certificate status
kubectl get certificates -n vault

# Verify certificate details
kubectl describe certificate vault-tls-cert -n vault

# Test HTTPS endpoint
curl -s https://vault.david-joo.sbx.hashidemos.io/v1/sys/health | jq
```

## Testing and Validation

### Infrastructure Testing

1. **Network Connectivity**:
   ```bash
   # Test bastion host SSH access
   ssh -i <key-file> ubuntu@<bastion-ip>
   
   # Test private subnet connectivity from bastion
   kubectl get pods -n vault
   ```

2. **KMS Auto-Unseal**:
   ```bash
   # Verify Vault uses KMS (no manual unsealing required)
   kubectl exec vault-0 -n vault -- vault status
   # Should show: Sealed: false
   ```

3. **High Availability**:
   ```bash
   # Test HA by deleting a pod
   kubectl delete pod vault-1 -n vault
   kubectl get pods -n vault
   # Pod should be recreated automatically
   ```

### SSL/TLS Testing

1. **Certificate Validation**:
   ```bash
   # Check SSL certificate in browser (should show valid Let's Encrypt cert)
   openssl s_client -connect vault.david-joo.sbx.hashidemos.io:443 -servername vault.david-joo.sbx.hashidemos.io
   ```

2. **Automatic Renewal**:
   ```bash
   # Check certificate expiry and renewal time
   kubectl get certificate vault-tls-cert -n vault -o yaml
   # Look for renewal_time field
   ```

### Application Testing

1. **Vault UI Access**:
   - Open <https://vault.david-joo.sbx.hashidemos.io:8200> in browser
   - Login with root token
   - Verify cluster status shows 3 active nodes

2. **API Testing**:
   ```bash
   # Health check
   curl https://vault.david-joo.sbx.hashidemos.io/v1/sys/health
   
   # Authentication test
   export VAULT_ADDR="https://vault.david-joo.sbx.hashidemos.io:8200"
   export VAULT_TOKEN="<root-token>"
   vault status
   ```

## Troubleshooting Guide

### SSL Certificate Issues

**Problem**: Certificate stuck in "Issuing" state
```bash
kubectl describe certificate vault-tls-cert -n vault
```

**Solutions**:
1. Verify DNS record exists and points to LoadBalancer
2. Check Let's Encrypt challenge pods:
   ```bash
   kubectl get pods -n vault | grep acme-http-solver
   ```
3. Verify ingress configuration allows HTTP for challenge

### Vault Pod Issues

**Problem**: Vault pods not ready (0/1)
```bash
kubectl describe pod vault-0 -n vault
kubectl logs vault-0 -n vault
```

**Common Causes**:
1. TLS certificate not mounted properly
2. KMS permissions issues
3. Configuration errors in helm values

### LoadBalancer Issues

**Problem**: LoadBalancer stuck in pending state
```bash
kubectl get service -n ingress-nginx
```

**Solutions**:
1. Check AWS Load Balancer Controller logs
2. Verify security group rules allow traffic
3. Ensure subnets have proper tags for ELB

## Cleanup Process

To avoid AWS charges, clean up in reverse order:

```bash
# Remove Vault and Kubernetes resources
terraform destroy -target=module.solution-k8s-vault-ent -auto-approve

# Remove EKS cluster
terraform destroy -target=module.platform-k8s-eks -auto-approve

# Remove AWS infrastructure
terraform destroy -target=module.infra-aws -auto-approve

# Final cleanup
terraform destroy -auto-approve
```

**Note**: Generated files like `letsencrypt-*-issuer.yaml` and TLS certificates are automatically excluded from version control via `.gitignore` as they contain environment-specific configurations.

## Production Considerations

1. **Backup Strategy**: Implement automated Vault snapshot backups to S3
2. **Monitoring**: Deploy CloudWatch monitoring and alerting
3. **Security**:
   - Rotate root token immediately after setup
   - Enable audit logging
   - Implement proper RBAC policies
4. **Disaster Recovery**: Test recovery procedures regularly
5. **Scaling**: Monitor resource usage and scale node groups as needed

## Security Notes

- Root token is displayed during initialization - secure it immediately
- Recovery keys are only for emergency access
- All traffic uses TLS 1.2+ with Let's Encrypt certificates
- KMS keys are managed by AWS with automatic rotation available
- Network security enforced through security groups and NACLs

## Architecture Decisions Explained

### Multi-Stage Deployment Rationale

1. **Dependency Management**: Ensures resources exist before dependent resources are created
2. **Error Isolation**: Easier to debug issues when deployment is broken into logical stages  
3. **Rollback Capability**: Can roll back specific layers without affecting others
4. **Resource Timing**: Handles AWS resource provisioning delays gracefully

### Why AWS KMS Auto-Unseal?

1. **Security**: Eliminates need to store unseal keys
2. **Automation**: Vault automatically unseals after restarts
3. **Compliance**: Meets enterprise security requirements
4. **Operational Simplicity**: No manual intervention required for restarts

### Why Let's Encrypt over AWS ACM?

1. **Kubernetes Integration**: Works seamlessly with cert-manager
2. **Automatic Renewal**: Fully automated certificate lifecycle
3. **Cost**: Free certificates with automated management
4. **Portability**: Not tied to AWS ALB, works with any ingress controller

This approach provides a robust, production-ready Vault deployment with proper SSL termination, high availability, and enterprise security features.