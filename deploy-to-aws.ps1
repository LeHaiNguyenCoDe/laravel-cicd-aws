# Laravel CI/CD AWS Deployment Script
# One-click deployment to AWS production

param(
    [switch]$SetupAWS,
    [switch]$Deploy,
    [switch]$Status,
    [switch]$Help
)

Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  Laravel CI/CD - AWS Deployment" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host ""

function Show-Help {
    Write-Host "Available Commands:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  .\deploy-to-aws.ps1 -SetupAWS    # Setup AWS credentials and IAM user"
    Write-Host "  .\deploy-to-aws.ps1 -Deploy      # Deploy to AWS production"
    Write-Host "  .\deploy-to-aws.ps1 -Status      # Check deployment status"
    Write-Host "  .\deploy-to-aws.ps1 -Help        # Show this help"
    Write-Host ""
    Write-Host "Quick Start:" -ForegroundColor Yellow
    Write-Host "1. Run: .\deploy-to-aws.ps1 -SetupAWS"
    Write-Host "2. Add AWS credentials to GitHub Secrets"
    Write-Host "3. Run: .\deploy-to-aws.ps1 -Deploy"
    Write-Host ""
}

function Setup-AWS {
    Write-Host "Setting up AWS for deployment..." -ForegroundColor Cyan
    Write-Host ""
    
    # Check if AWS CLI is installed
    try {
        $awsVersion = aws --version
        Write-Host "AWS CLI found: $awsVersion" -ForegroundColor Green
    } catch {
        Write-Host "AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
        Write-Host "Download: https://aws.amazon.com/cli/"
        return
    }
    
    # Check AWS credentials
    try {
        $identity = aws sts get-caller-identity 2>$null
        if ($identity) {
            Write-Host "AWS credentials configured" -ForegroundColor Green
            $identity | ConvertFrom-Json | Format-Table
        }
    } catch {
        Write-Host "AWS credentials not configured" -ForegroundColor Yellow
        Write-Host "Run: aws configure"
        return
    }
    
    Write-Host "Creating IAM user for GitHub Actions..." -ForegroundColor Cyan
    
    # Create IAM user
    try {
        aws iam create-user --user-name github-actions-user 2>$null
        Write-Host "IAM user created: github-actions-user" -ForegroundColor Green
    } catch {
        Write-Host "IAM user may already exist" -ForegroundColor Yellow
    }
    
    # Create access key
    Write-Host "Creating access key..." -ForegroundColor Cyan
    try {
        $accessKey = aws iam create-access-key --user-name github-actions-user | ConvertFrom-Json
        Write-Host "Access key created!" -ForegroundColor Green
        Write-Host ""
        Write-Host "GitHub Secrets to add:" -ForegroundColor Yellow
        Write-Host "AWS_ACCESS_KEY_ID: $($accessKey.AccessKey.AccessKeyId)"
        Write-Host "AWS_SECRET_ACCESS_KEY: $($accessKey.AccessKey.SecretAccessKey)"
        Write-Host ""
        Write-Host "Add these to: GitHub Repository > Settings > Secrets > Actions" -ForegroundColor Cyan
    } catch {
        Write-Host "Failed to create access key" -ForegroundColor Red
    }
    
    # Attach policies
    Write-Host "Attaching IAM policies..." -ForegroundColor Cyan
    $policies = @(
        "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
        "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
        "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
        "arn:aws:iam::aws:policy/ElastiCacheFullAccess"
    )
    
    foreach ($policy in $policies) {
        try {
            aws iam attach-user-policy --user-name github-actions-user --policy-arn $policy
            Write-Host "Attached: $($policy.Split('/')[-1])" -ForegroundColor Green
        } catch {
            Write-Host "Failed to attach: $($policy.Split('/')[-1])" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Green
    Write-Host "1. Add the AWS credentials to GitHub Secrets"
    Write-Host "2. Run: .\deploy-to-aws.ps1 -Deploy"
}

function Deploy-ToAWS {
    Write-Host "Deploying to AWS production..." -ForegroundColor Cyan
    Write-Host ""
    
    # Check if we're in a git repository
    try {
        $gitStatus = git status 2>$null
        Write-Host "Git repository detected" -ForegroundColor Green
    } catch {
        Write-Host "Not in a git repository" -ForegroundColor Red
        return
    }
    
    # Check if GitHub remote exists
    try {
        $remoteUrl = git remote get-url origin
        Write-Host "GitHub remote: $remoteUrl" -ForegroundColor Green
    } catch {
        Write-Host "No GitHub remote configured" -ForegroundColor Red
        Write-Host "Add remote: git remote add origin https://github.com/USERNAME/REPO.git"
        return
    }
    
    Write-Host "Triggering deployment..." -ForegroundColor Cyan
    
    # Create deployment commit
    git add .
    $commitMessage = "Deploy to AWS production - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $commitMessage
    
    # Push to trigger CI/CD
    git push origin main
    
    Write-Host "Deployment triggered!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Monitor deployment:" -ForegroundColor Cyan
    Write-Host "• GitHub Actions: $remoteUrl/actions"
    Write-Host "• AWS Console: https://console.aws.amazon.com/ecs/"
    Write-Host ""
    Write-Host "Expected deployment time: 15-20 minutes"
}

function Check-Status {
    Write-Host "Checking deployment status..." -ForegroundColor Cyan
    Write-Host ""
    
    # Check AWS CLI
    try {
        aws --version | Out-Null
        Write-Host "AWS CLI available" -ForegroundColor Green
    } catch {
        Write-Host "AWS CLI not available" -ForegroundColor Red
        return
    }
    
    # Check ECS cluster
    try {
        $cluster = aws ecs describe-clusters --clusters laravel-cluster 2>$null | ConvertFrom-Json
        if ($cluster.clusters.Count -gt 0) {
            Write-Host "ECS Cluster: laravel-cluster" -ForegroundColor Green
            Write-Host "   Status: $($cluster.clusters[0].status)"
            Write-Host "   Tasks: $($cluster.clusters[0].runningTasksCount) running, $($cluster.clusters[0].pendingTasksCount) pending"
        } else {
            Write-Host "ECS Cluster not found" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Cannot check ECS cluster" -ForegroundColor Yellow
    }
    
    # Check ECS service
    try {
        $service = aws ecs describe-services --cluster laravel-cluster --services laravel-service 2>$null | ConvertFrom-Json
        if ($service.services.Count -gt 0) {
            Write-Host "ECS Service: laravel-service" -ForegroundColor Green
            Write-Host "   Status: $($service.services[0].status)"
            Write-Host "   Desired: $($service.services[0].desiredCount), Running: $($service.services[0].runningCount)"
        } else {
            Write-Host "ECS Service not found" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Cannot check ECS service" -ForegroundColor Yellow
    }
    
    # Check ECR repository
    try {
        $repo = aws ecr describe-repositories --repository-names laravel-app 2>$null | ConvertFrom-Json
        if ($repo.repositories.Count -gt 0) {
            Write-Host "ECR Repository: laravel-app" -ForegroundColor Green
            Write-Host "   URI: $($repo.repositories[0].repositoryUri)"
        } else {
            Write-Host "ECR Repository not found" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Cannot check ECR repository" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Useful Commands:" -ForegroundColor Cyan
    Write-Host "aws ecs describe-services --cluster laravel-cluster --services laravel-service"
    Write-Host "aws logs tail /ecs/laravel-app --follow"
    Write-Host "aws elbv2 describe-load-balancers"
}

# Main execution
if ($Help -or (!$SetupAWS -and !$Deploy -and !$Status)) {
    Show-Help
} elseif ($SetupAWS) {
    Setup-AWS
} elseif ($Deploy) {
    Deploy-ToAWS
} elseif ($Status) {
    Check-Status
}

Write-Host ""
Write-Host "Laravel CI/CD AWS Deployment Tool" -ForegroundColor Green
Write-Host "For help: .\deploy-to-aws.ps1 -Help" -ForegroundColor Cyan
