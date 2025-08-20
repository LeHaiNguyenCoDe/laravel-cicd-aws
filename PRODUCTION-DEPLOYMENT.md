# 🚀 Production Deployment Guide

Complete guide for deploying Laravel CI/CD pipeline to AWS production.

## 🎯 **Quick Start**

### **Option 1: Automatic AWS Detection (Recommended)**
```bash
# 1. Add AWS credentials to GitHub Secrets
# 2. Push any commit - pipeline auto-detects and deploys to AWS
git commit --allow-empty -m "Deploy to AWS production"
git push
```

### **Option 2: Use Production Branch**
```bash
# Switch to production branch
git checkout production
git push origin production
```

---

## 🔐 **AWS Setup**

### **1. Create IAM User**
```bash
# Using AWS CLI
aws iam create-user --user-name github-actions-user

# Create access key
aws iam create-access-key --user-name github-actions-user

# Attach required policies
aws iam attach-user-policy --user-name github-actions-user --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess
aws iam attach-user-policy --user-name github-actions-user --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws iam attach-user-policy --user-name github-actions-user --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess
aws iam attach-user-policy --user-name github-actions-user --policy-arn arn:aws:iam::aws:policy/AmazonRDSFullAccess
aws iam attach-user-policy --user-name github-actions-user --policy-arn arn:aws:iam::aws:policy/ElastiCacheFullAccess
```

### **2. Add GitHub Secrets**
Go to: `GitHub Repository > Settings > Secrets and variables > Actions`

Add these secrets:
- **AWS_ACCESS_KEY_ID**: `AKIA...`
- **AWS_SECRET_ACCESS_KEY**: `wJalrXUt...`

---

## 🏗️ **Infrastructure Created**

### **AWS Resources**
- **VPC** with public/private subnets across 2 AZs
- **Application Load Balancer** with SSL termination
- **ECS Fargate** cluster and service
- **ECR** container registry
- **RDS MySQL** database (db.t3.micro)
- **ElastiCache Redis** cluster (cache.t3.micro)
- **NAT Gateway** for outbound traffic
- **Security Groups** with minimal access
- **CloudWatch** logs and monitoring

### **Cost Estimation**
| Service | Instance Type | Monthly Cost |
|---------|---------------|--------------|
| ECS Fargate | 0.25 vCPU, 0.5 GB | $15-30 |
| RDS MySQL | db.t3.micro | $15 |
| ElastiCache | cache.t3.micro | $15 |
| Application LB | Standard | $20 |
| NAT Gateway | Standard | $45 |
| **Total** | | **~$110-125** |

---

## 📊 **Monitoring & URLs**

### **Application URLs**
- **Main App**: `https://your-alb-dns.amazonaws.com`
- **Health Check**: `https://your-alb-dns.amazonaws.com/health`
- **Status**: `https://your-alb-dns.amazonaws.com/status`
- **Metrics**: `https://your-alb-dns.amazonaws.com/metrics`
- **Security**: `https://your-alb-dns.amazonaws.com/security`

### **AWS Console URLs**
- **ECS**: https://console.aws.amazon.com/ecs/
- **ECR**: https://console.aws.amazon.com/ecr/
- **CloudWatch**: https://console.aws.amazon.com/cloudwatch/
- **Load Balancer**: https://console.aws.amazon.com/ec2/v2/home#LoadBalancers

---

## 🔧 **Management Commands**

### **AWS CLI Commands**
```bash
# Check ECS service status
aws ecs describe-services --cluster laravel-cluster --services laravel-service

# View application logs
aws logs tail /ecs/laravel-app --follow

# Check ECR repositories
aws ecr describe-repositories

# Scale ECS service
aws ecs update-service --cluster laravel-cluster --service laravel-service --desired-count 2

# Check load balancer
aws elbv2 describe-load-balancers

# View RDS instances
aws rds describe-db-instances
```

### **Local Development**
```bash
# Start local development
make dev

# Run tests
make test

# Build production image
make build

# Deploy infrastructure only
make deploy-infra

# View all commands
make help
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Deployment Fails**
```bash
# Check GitHub Actions logs
# Go to Actions tab > Click failed run > Check logs

# Check ECS service events
aws ecs describe-services --cluster laravel-cluster --services laravel-service
```

#### **2. Application Not Accessible**
```bash
# Check load balancer health
aws elbv2 describe-target-health --target-group-arn YOUR_TARGET_GROUP_ARN

# Check security groups
aws ec2 describe-security-groups --group-names laravel-app-*
```

#### **3. Database Connection Issues**
```bash
# Check RDS status
aws rds describe-db-instances

# Test connection from ECS task
aws ecs execute-command --cluster laravel-cluster --task TASK_ID --interactive --command "/bin/bash"
```

### **Debug Commands**
```bash
# View ECS task logs
aws logs get-log-events --log-group-name /ecs/laravel-app --log-stream-name STREAM_NAME

# Check task definition
aws ecs describe-task-definition --task-definition laravel-app

# View service events
aws ecs describe-services --cluster laravel-cluster --services laravel-service --query 'services[0].events'
```

---

## 🔒 **Security Best Practices**

### **Implemented Security**
- ✅ **Non-root container** execution
- ✅ **Private subnets** for application
- ✅ **Security groups** with minimal access
- ✅ **SSL/TLS** termination at load balancer
- ✅ **Environment variables** for secrets
- ✅ **Database encryption** at rest
- ✅ **VPC isolation** from internet

### **Additional Recommendations**
- 🔐 **AWS Secrets Manager** for database credentials
- 🛡️ **AWS WAF** for web application firewall
- 📊 **AWS GuardDuty** for threat detection
- 🔍 **AWS Config** for compliance monitoring
- 📝 **AWS CloudTrail** for audit logging

---

## 🎯 **Next Steps**

### **1. Custom Domain**
```bash
# Create Route 53 hosted zone
aws route53 create-hosted-zone --name yourdomain.com --caller-reference $(date +%s)

# Request SSL certificate
aws acm request-certificate --domain-name yourdomain.com --validation-method DNS
```

### **2. Enhanced Monitoring**
- Setup CloudWatch dashboards
- Configure CloudWatch alarms
- Add application performance monitoring (APM)
- Setup log aggregation

### **3. Scaling & Performance**
- Configure auto-scaling policies
- Setup CloudFront CDN
- Optimize database performance
- Add Redis caching

### **4. CI/CD Enhancements**
- Add staging environment
- Implement blue-green deployments
- Add automated security scanning
- Setup dependency vulnerability checks

---

**🎉 Your Laravel application is now production-ready on AWS with complete CI/CD pipeline! 🚀**
