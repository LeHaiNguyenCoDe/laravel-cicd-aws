# Laravel CI/CD Makefile
# Easy commands for development and deployment

.PHONY: help install dev build test deploy clean

# Default target
help: ## Show this help message
	@echo "🚀 Laravel CI/CD Commands"
	@echo "========================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development commands
install: ## Install dependencies
	@echo "📦 Installing dependencies..."
	composer install
	npm install
	cp .env.example .env
	php artisan key:generate

dev: ## Start development environment
	@echo "🚀 Starting development environment..."
	docker-compose up -d
	@echo "✅ Development environment started!"
	@echo "🌐 Application: http://localhost:8080"
	@echo "🗄️ Database: localhost:3306"
	@echo "🔴 Redis: localhost:6379"

dev-build: ## Build and start development environment
	@echo "🏗️ Building development environment..."
	docker-compose up -d --build

dev-stop: ## Stop development environment
	@echo "🛑 Stopping development environment..."
	docker-compose down

dev-logs: ## Show development logs
	docker-compose logs -f

# Testing commands
test: ## Run tests
	@echo "🧪 Running tests..."
	php artisan test

test-coverage: ## Run tests with coverage
	@echo "🧪 Running tests with coverage..."
	php artisan test --coverage

# Build commands
build: ## Build production Docker image
	@echo "🏗️ Building production Docker image..."
	docker build -t laravel-app:latest .

build-dev: ## Build development Docker image
	@echo "🏗️ Building development Docker image..."
	docker build --target development -t laravel-app:dev .

# Deployment commands
deploy-setup: ## Setup AWS infrastructure and CI/CD
	@echo "🚀 Setting up AWS deployment..."
	chmod +x ../deploy-to-aws.sh
	../deploy-to-aws.sh

deploy-infra: ## Deploy infrastructure only
	@echo "🏗️ Deploying infrastructure..."
	cd terraform && terraform init && terraform apply

deploy-app: ## Deploy application only
	@echo "🚀 Deploying application..."
	@echo "Push to main/master branch to trigger deployment"

# Database commands
db-migrate: ## Run database migrations
	@echo "🗄️ Running migrations..."
	php artisan migrate

db-seed: ## Seed database
	@echo "🌱 Seeding database..."
	php artisan db:seed

db-fresh: ## Fresh database with seeds
	@echo "🔄 Fresh database..."
	php artisan migrate:fresh --seed

# Cache commands
cache-clear: ## Clear all caches
	@echo "🧹 Clearing caches..."
	php artisan cache:clear
	php artisan config:clear
	php artisan route:clear
	php artisan view:clear

cache-optimize: ## Optimize for production
	@echo "⚡ Optimizing for production..."
	php artisan config:cache
	php artisan route:cache
	php artisan view:cache
	composer dump-autoload --optimize

# Asset commands
assets-dev: ## Build development assets
	@echo "🎨 Building development assets..."
	npm run dev

assets-build: ## Build production assets
	@echo "🎨 Building production assets..."
	npm run build

assets-watch: ## Watch assets for changes
	@echo "👀 Watching assets..."
	npm run dev -- --watch

# Quality commands
lint: ## Run code linting
	@echo "🔍 Running linting..."
	./vendor/bin/phpcs --standard=PSR12 app/
	npm run lint

fix: ## Fix code style issues
	@echo "🔧 Fixing code style..."
	./vendor/bin/phpcbf --standard=PSR12 app/
	npm run lint:fix

# Security commands
security: ## Run security checks
	@echo "🔒 Running security checks..."
	composer audit
	npm audit

# Cleanup commands
clean: ## Clean up containers and volumes
	@echo "🧹 Cleaning up..."
	docker-compose down -v
	docker system prune -f

clean-all: ## Clean everything including images
	@echo "🧹 Cleaning everything..."
	docker-compose down -v --rmi all
	docker system prune -af

# Logs commands
logs: ## Show application logs
	tail -f storage/logs/laravel.log

logs-docker: ## Show Docker logs
	docker-compose logs -f app

# Status commands
status: ## Show service status
	@echo "📊 Service Status:"
	@echo "=================="
	docker-compose ps

health: ## Check application health
	@echo "🏥 Health Check:"
	@echo "================"
	curl -f http://localhost:8080/health || echo "❌ Application not healthy"

# AWS commands
aws-login: ## Login to AWS ECR
	@echo "🔐 Logging into AWS ECR..."
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

aws-push: ## Push image to ECR
	@echo "📤 Pushing to ECR..."
	$(MAKE) aws-login
	docker tag laravel-app:latest $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/laravel-app:latest
	docker push $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/laravel-app:latest

# Info commands
info: ## Show project information
	@echo "📋 Project Information:"
	@echo "======================"
	@echo "Laravel Version: $(shell php artisan --version)"
	@echo "PHP Version: $(shell php --version | head -n 1)"
	@echo "Composer Version: $(shell composer --version)"
	@echo "Node Version: $(shell node --version)"
	@echo "NPM Version: $(shell npm --version)"
	@echo "Docker Version: $(shell docker --version)"
