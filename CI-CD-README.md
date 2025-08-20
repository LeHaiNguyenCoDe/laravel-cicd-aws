# 🚀 Laravel CI/CD Pipeline with AWS

Complete CI/CD solution for Laravel applications using GitHub Actions, Docker, and AWS services.

## 📋 **What's Included**

### 🏗️ **Infrastructure**
- **AWS ECS Fargate** - Serverless container hosting
- **Application Load Balancer** - High availability and SSL termination
- **RDS MySQL** - Managed database service
- **ElastiCache Redis** - Caching and session storage
- **ECR** - Container registry
- **VPC** - Secure networking
- **CloudWatch** - Logging and monitoring

### 🔄 **CI/CD Pipeline**
- **GitHub Actions** - Automated testing and deployment
- **Multi-stage Docker builds** - Optimized container images
- **Automated testing** - PHPUnit tests with MySQL
- **Security scanning** - Container vulnerability scanning
- **Zero-downtime deployment** - Rolling updates

### 🛠️ **Development Tools**
- **Docker Compose** - Local development environment
- **Makefile** - Easy command shortcuts
- **Code quality tools** - Linting and formatting
- **Health checks** - Application monitoring

---

## ⚡ **Quick Start**

### 1. **Setup AWS Infrastructure**
```bash
# Make script executable
chmod +x deploy-to-aws.sh

# Run deployment script
./deploy-to-aws.sh
```

### 2. **Configure GitHub Secrets**
Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 3. **Deploy Application**
```bash
# Push to main branch to trigger deployment
git push origin main
```

---

## 🔧 **Local Development**

### **Start Development Environment**
```bash
# Using Makefile (recommended)
make dev

# Or using Docker Compose directly
docker-compose up -d
```

### **Available URLs**
- **Application**: http://localhost:8080
- **Alternative Nginx**: http://localhost:8081
- **Database**: localhost:3306
- **Redis**: localhost:6379

### **Useful Commands**
```bash
# Install dependencies
make install

# Run tests
make test

# Build assets
make assets-dev

# View logs
make logs

# Stop environment
make dev-stop
```

---

## 🚀 **Deployment Process**

### **Automatic Deployment (GitHub Actions)**
1. **Push to main/master branch**
2. **Tests run automatically**
3. **Docker image builds**
4. **Image pushes to ECR**
5. **ECS service updates**
6. **Health checks verify deployment**

### **Manual Deployment**
```bash
# Build and push image
make build
make aws-push

# Update ECS service (via AWS CLI)
aws ecs update-service --cluster laravel-cluster --service laravel-service --force-new-deployment
```

---

## 📊 **Monitoring & Logs**

### **Application Logs**
```bash
# Local logs
make logs

# AWS CloudWatch logs
aws logs tail /ecs/laravel-app --follow
```

### **Health Checks**
```bash
# Local health check
make health

# Production health check
curl https://your-domain.com/health
```

### **Service Status**
```bash
# Local status
make status

# AWS ECS status
aws ecs describe-services --cluster laravel-cluster --services laravel-service
```

---

## 🔒 **Security Features**

### **Container Security**
- ✅ Non-root user execution
- ✅ Minimal base images (Alpine Linux)
- ✅ Security scanning in CI/CD
- ✅ Read-only root filesystem
- ✅ No unnecessary packages

### **Network Security**
- ✅ Private subnets for application
- ✅ Security groups with minimal access
- ✅ NAT Gateway for outbound traffic
- ✅ Application Load Balancer with SSL

### **Application Security**
- ✅ Environment variables for secrets
- ✅ AWS Secrets Manager integration
- ✅ Database encryption at rest
- ✅ Redis AUTH enabled

---

## 🎯 **Production Optimizations**

### **Performance**
- ✅ OPcache enabled
- ✅ Redis caching
- ✅ Optimized Composer autoloader
- ✅ Laravel config/route/view caching
- ✅ Nginx gzip compression

### **Scalability**
- ✅ Auto-scaling ECS service
- ✅ Multi-AZ deployment
- ✅ Load balancer health checks
- ✅ Horizontal pod autoscaling

### **Reliability**
- ✅ Health checks at multiple levels
- ✅ Graceful shutdown handling
- ✅ Database connection pooling
- ✅ Circuit breaker patterns

---

## 📁 **File Structure**

```
laravel/
├── .github/workflows/deploy.yml    # GitHub Actions CI/CD
├── .docker/                        # Docker configuration
│   ├── nginx.conf                  # Nginx configuration
│   ├── php-fpm.conf               # PHP-FPM configuration
│   ├── supervisord.conf           # Supervisor configuration
│   └── php.ini                    # PHP configuration
├── .aws/                          # AWS configuration
│   └── task-definition.json       # ECS task definition
├── terraform/                     # Infrastructure as Code
│   └── main.tf                    # Terraform configuration
├── Dockerfile                     # Multi-stage Docker build
├── docker-compose.yml             # Local development
├── Makefile                       # Development commands
└── CI-CD-README.md                # This file
```

---

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **Build Failures**
```bash
# Check build logs
docker build -t laravel-app:latest .

# Check GitHub Actions logs
# Go to Actions tab in GitHub repository
```

#### **Deployment Issues**
```bash
# Check ECS service events
aws ecs describe-services --cluster laravel-cluster --services laravel-service

# Check task logs
aws logs tail /ecs/laravel-app --follow
```

#### **Database Connection Issues**
```bash
# Check security groups
aws ec2 describe-security-groups --group-names laravel-app-rds-*

# Test database connection
php artisan tinker
DB::connection()->getPdo();
```

---

## 📞 **Support**

### **Useful Commands**
```bash
# Show all available commands
make help

# Check project information
make info

# Run security checks
make security

# Clean up resources
make clean
```

### **AWS Resources**
- **ECS Console**: https://console.aws.amazon.com/ecs/
- **ECR Console**: https://console.aws.amazon.com/ecr/
- **CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch/

---

**🎉 Your Laravel application is now ready for production with complete CI/CD pipeline!**
