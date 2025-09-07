#!/usr/bin/env bash
set -euo pipefail

# Tools (Mac)
command -v aws >/dev/null || brew install awscli
command -v kubectl >/dev/null || brew install kubectl
command -v terraform >/dev/null || brew install terraform
command -v jq >/dev/null || brew install jq
command -v direnv >/dev/null || brew install direnv

# Repo-scoped env (direnv)
cat > .envrc <<'EOF'
export AWS_PROFILE=admin-yusef
export AWS_REGION=us-east-1
export AWS_SDK_LOAD_CONFIG=1
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
EOF
direnv allow

# Terraform backend sanity
make tf-init || true

echo "Bootstrap complete. Open a new shell or 'exec -l $SHELL'."

