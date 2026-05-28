#!/bin/bash

set -euo pipefail

ENVIRONMENT=${1:-dev}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

if [ ! -d "$ENV_DIR" ]; then
  echo "❌ Environment '$ENVIRONMENT' not found at $ENV_DIR"
  exit 1
fi

echo "⚠️  WARNING: This will destroy all resources in $ENVIRONMENT environment!"
read -r -p "Are you sure? Type '$ENVIRONMENT' to confirm: " confirmation

if [ "$confirmation" != "$ENVIRONMENT" ]; then
  echo "Destruction cancelled."
  exit 0
fi

echo "🗑️  Destroying $ENVIRONMENT environment..."

# Init
terraform -chdir="$ENV_DIR" init

# Empty S3 bucket first (must be done before destroy)
echo "🪣 Emptying S3 bucket..."
BUCKET_NAME="dev-frontend-926827028763"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    aws s3 rm "s3://$BUCKET_NAME" --recursive
    echo "✅ S3 bucket emptied"
else
    echo "ℹ️  S3 bucket not found, skipping"
fi

# Destroy
terraform -chdir="$ENV_DIR" destroy -var-file="terraform.tfvars" -auto-approve

echo "✅ $ENVIRONMENT environment destroyed!"