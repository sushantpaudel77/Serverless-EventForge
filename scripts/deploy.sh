#!/bin/bash

set -euo pipefail

ENVIRONMENT=${1:-dev}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

if [ ! -d "$ENV_DIR" ]; then
  echo "❌ Environment '$ENVIRONMENT' not found at $ENV_DIR"
  exit 1
fi

echo "🚀 Deploying infrastructure + frontend to $ENVIRONMENT..."

# Terraform
echo "📦 Initializing Terraform..."
terraform -chdir="$ENV_DIR" init -upgrade

echo "✅ Validating configuration..."
terraform -chdir="$ENV_DIR" validate

echo "📋 Planning changes..."
terraform -chdir="$ENV_DIR" plan -var-file="terraform.tfvars" -out=tfplan

echo "🔧 Applying changes..."
terraform -chdir="$ENV_DIR" apply tfplan

# Frontend (only if frontend directory exists)
if [ -d "$FRONTEND_DIR" ]; then
  echo "📤 Building frontend..."
  npm --prefix "$FRONTEND_DIR" ci
  npm --prefix "$FRONTEND_DIR" run build

  BUCKET="$(terraform -chdir="$ENV_DIR" output -raw frontend_bucket_name)"
  CF_ID="$(terraform -chdir="$ENV_DIR" output -raw cloudfront_id)"

  echo "☁️ Uploading dist to s3://$BUCKET ..."
  aws s3 sync "$FRONTEND_DIR/dist/" "s3://$BUCKET" --delete
  aws s3 cp "$FRONTEND_DIR/dist/index.html" "s3://$BUCKET/index.html" \
    --cache-control "max-age=0,no-cache,no-store,must-revalidate" \
    --content-type "text/html"

  echo "🧹 Invalidating CloudFront cache..."
  aws cloudfront create-invalidation --distribution-id "$CF_ID" --paths "/*" >/dev/null
fi

echo "📊 Deployment complete! Outputs:"
terraform -chdir="$ENV_DIR" output

echo "✨ Done. Infra + frontend deployed for $ENVIRONMENT."