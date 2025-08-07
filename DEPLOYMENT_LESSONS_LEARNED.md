# Deployment Lessons Learned - Vault Enterprise on EKS

This document captures the specific challenges we encountered during the deployment and their solutions.

## Initial Problem: Single-Stage Deployment Failures

### What We Tried
Initial approach was a single `terraform apply` command expecting all resources to deploy successfully.

### What Went Wrong
- **VPC Limit Exceeded**: AWS account had 5/5 VPCs in use, preventing new VPC creation
- **Resource Dependencies**: EKS cluster tried to deploy before VPC was ready
- **SSL Certificate Timing**: Route53 records attempted creation before LoadBalancer had external IP
- **DNS Propagation**: Let's Encrypt certificate validation failed due to DNS not being available

### Solution: Multi-Stage Approach
We implemented a three-stage deployment process:

```
Stage 1: AWS Infrastructure (VPC, KMS, Security Groups)
    ↓
Stage 2: EKS Platform (Cluster, Nodes, OIDC)
    ↓  
Stage 3: Vault Solution (Helm, SSL, Ingress)
```

## Specific Issues and Resolutions

### 1. VPC Cleanup Challenge

**Problem**: AWS VPC limit exceeded (5/5 VPCs in use)

**Investigation Process**:
```bash
# Listed all VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].{VpcId:VpcId,CidrBlock:CidrBlock,IsDefault:IsDefault,State:State}'

# Found VPCs that could be deleted
aws ec2 describe-vpcs --vpc-ids vpc-xyz123 --query 'Vpcs[*].Tags'
```

**Cleanup Complications**:
- Security groups had cross-references preventing deletion
- Manual deletion required careful dependency resolution

**Solution Steps**:
```bash
# 1. Identify cross-referencing security groups
aws ec2 describe-security-groups --group-ids sg-xyz123 --query 'SecurityGroups[*].IpPermissions[*].UserIdGroupPairs'

# 2. Remove security group rules first
aws ec2 revoke-security-group-ingress --group-id sg-source --source-group sg-target --protocol tcp --port 443

# 3. Delete security groups
aws ec2 delete-security-group --group-id sg-xyz123

# 4. Finally delete VPC
aws ec2 delete-vpc --vpc-id vpc-xyz123
```

### 2. SSL Certificate Provisioning Timing

**Problem**: Certificate stuck in "Issuing" state

**Root Cause**: Multiple timing dependencies
1. LoadBalancer needed external IP before Route53 record creation
2. DNS record needed propagation before Let's Encrypt validation
3. HTTP-01 challenge needed ingress to allow HTTP traffic

**Debugging Process**:
```bash
# Check certificate status
kubectl describe certificate vault-tls-cert -n vault

# Check challenge pods
kubectl get pods -n vault | grep acme-http-solver

# Verify DNS resolution
nslookup vault.david-joo.sbx.hashidemos.io

# Check LoadBalancer status
kubectl get service -n ingress-nginx ingress-nginx-controller
```

**Solution**: Wait for each dependency:
1. Wait for LoadBalancer external IP
2. Create Route53 record
3. Wait for DNS propagation (30-60 seconds)
4. Let cert-manager handle the rest

### 3. Ingress SSL Proxy Configuration

**Problem**: Vault UI returned SSL errors when accessed through ingress

**Initial Configuration** (incorrect):
```yaml
annotations:
  nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  # Missing proxy SSL settings
```

**Root Cause**: NGINX was trying to verify Vault's self-signed certificates

**Correct Configuration**:
```yaml
annotations:
  nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  nginx.ingress.kubernetes.io/proxy-ssl-verify: "off"
  nginx.ingress.kubernetes.io/proxy-ssl-server-name: "on"
```

**Why This Works**:
- `proxy-ssl-verify: off` - Disables backend certificate verification
- `proxy-ssl-server-name: on` - Enables SNI for proper SSL handshake
- NGINX handles SSL termination with Let's Encrypt cert, internal communication uses Vault's self-signed cert

### 4. Vault KMS Auto-Unseal Configuration

**Problem**: Initial Vault initialization attempted with manual unseal parameters

**What We Tried First**:
```bash
vault operator init -key-shares=1 -key-threshold=1
```

**Error**:
```
parameters secret_shares,secret_threshold not applicable to seal type awskms
```

**Correct Approach**:
```bash
vault operator init -format=json
```

**Key Learning**: With AWS KMS auto-unseal:
- No unseal keys are generated
- Recovery keys are provided instead
- Vault automatically unseals after restarts
- Only recovery keys needed for disaster recovery

### 5. Terraform State Management Issues

**Problem**: Manual AWS resource deletion left Terraform state inconsistent

**Symptoms**:
- Terraform tried to create resources that already existed
- State file referenced deleted resources
- Subsequent applies failed with resource conflicts

**Solution Process**:
```bash
# Refresh state to match reality
terraform refresh

# Import manually created resources
terraform import aws_vpc.main vpc-xyz123

# Remove deleted resources from state
terraform state rm aws_vpc.deleted_vpc
```

**Prevention**: Use `terraform destroy` instead of manual deletion where possible

## Testing Strategies That Worked

### 1. Infrastructure Verification
```bash
# Verify VPC and subnets
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*djoo*"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xyz123"

# Test EKS connectivity
kubectl get nodes
kubectl get pods --all-namespaces

# Verify KMS permissions
aws kms describe-key --key-id alias/vault-unseal
```

### 2. SSL/TLS Validation
```bash
# Check certificate chain
openssl s_client -connect vault.domain.com:443 -servername vault.domain.com

# Verify certificate details
kubectl get certificate vault-tls-cert -n vault -o yaml

# Test HTTPS endpoint
curl -s https://vault.domain.com/v1/sys/health | jq
```

### 3. High Availability Testing
```bash
# Test pod resilience
kubectl delete pod vault-1 -n vault
kubectl get pods -n vault --watch

# Test leader election
kubectl exec vault-0 -n vault -- vault status
kubectl exec vault-1 -n vault -- vault status
```

## Performance and Timing Observations

### Resource Provisioning Times
- **VPC Creation**: 30-60 seconds
- **EKS Cluster**: 8-12 minutes
- **Node Group**: 3-5 minutes
- **LoadBalancer**: 2-3 minutes for external IP
- **DNS Propagation**: 30-90 seconds
- **SSL Certificate**: 2-5 minutes after DNS ready

### Critical Path Dependencies
```
VPC → Subnets → EKS Cluster → Node Group → Pods → LoadBalancer → DNS → SSL Certificate
```

## Recommended Deployment Flow

Based on our experience, the optimal deployment sequence is:

1. **Pre-deployment Checks**:
   ```bash
   # Check VPC limits
   aws service-quotas get-service-quota --service-code vpc --quota-code L-F678F1CE
   
   # Verify permissions
   aws sts get-caller-identity
   ```

2. **Stage 1: Infrastructure**:
   ```bash
   terraform apply -target=module.infra-aws -auto-approve
   ```

3. **Validation Checkpoint**:
   ```bash
   # Verify VPC and KMS
   aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=${DEPLOYMENT_ID}"
   aws kms list-aliases | grep vault
   ```

4. **Stage 2: Platform**:
   ```bash
   terraform apply -target=module.platform-k8s-eks -auto-approve
   ```

5. **Validation Checkpoint**:
   ```bash
   # Test cluster access
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

6. **Stage 3: Solution**:
   ```bash
   terraform apply -auto-approve
   ```

7. **Post-deployment Verification**:
   ```bash
   # Wait for LoadBalancer
   kubectl get service -n ingress-nginx --watch
   
   # Verify DNS
   nslookup vault.domain.com
   
   # Check SSL certificate
   kubectl get certificates -n vault
   
   # Initialize Vault
   kubectl exec -it vault-0 -n vault -- vault operator init -format=json
   ```

## Automation Improvements for Future

### Terraform Enhancements
1. Add explicit dependencies using `depends_on`
2. Implement retry logic for timing-sensitive resources
3. Add validation checks between stages
4. Use data sources to wait for resource readiness

### Monitoring and Alerting
1. CloudWatch alarms for EKS cluster health
2. Certificate expiration monitoring
3. Vault seal status alerts
4. LoadBalancer health checks

### Backup and Recovery
1. Automated Vault snapshot backups to S3
2. EKS cluster backup strategy
3. Terraform state file backup
4. Disaster recovery runbooks

This experience demonstrates the importance of understanding AWS resource dependencies and implementing proper staging for complex deployments.
