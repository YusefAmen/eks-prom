# --- Config ---
SHELL := /bin/bash
TF_DIR := infra/terraform

# Base AWS creds profile you'll use locally
AWS_PROFILE ?= admin-yusef
AWS_REGION  ?= us-east-1

# Export so every recipe inherits these
export AWS_PROFILE
export AWS_REGION
export AWS_SDK_LOAD_CONFIG=1

# Terraform helper (so we don't cd all the time)
TF = terraform -chdir=$(TF_DIR)

# --- Phony targets ---
.PHONY: whoami tf-init tf-plan tf-apply tf-apply-auto tf-destroy-eks tf-destroy tf-destroy-auto \
        kubeconfig k-context k-get-nodes k-get-pods k-logs-kubeapi doctor

# --- AWS sanity ---
whoami:
	aws sts get-caller-identity

# --- Terraform ---
tf-init:
	$(TF) init -reconfigure -backend-config="profile=$(AWS_PROFILE)"

tf-validate:
	$(TF) validate

tf-plan:
	$(TF) plan

tf-apply:
	$(TF) apply

tf-apply-auto:
	$(TF) apply -auto-approve

tf-destroy-eks:
	$(TF) destroy -target=module.eks

tf-destroy:
	$(TF) destroy

tf-destroy-auto:
	$(TF) destroy -auto-approve

# --- EKS / kubectl ---
# Writes/updates kubeconfig so kubectl will assume your terraform-deployer role

kubeconfig:
	@aws eks update-kubeconfig \
	  --name "$$(terraform -chdir=$(TF_DIR) output -raw cluster_name)" \
	  --region "$(AWS_REGION)" \
	  --role-arn arn:aws:iam::142021135755:role/terraform-deployer \
	  --alias eks-prom
	@USER=$$(kubectl config view --raw --minify -o jsonpath='{.contexts[0].context.user}'); \
	echo "Binding exec env to kube user $$USER"; \
	kubectl config set-credentials "$$USER" \
	  --exec-env=AWS_PROFILE=$(AWS_PROFILE) \
	  --exec-env=AWS_SDK_LOAD_CONFIG=1


k-context:
	@kubectl config current-context

k-get-nodes:
	@kubectl get nodes -o wide

k-get-pods:
	@kubectl get pods -A -o wide

# Handy when API auth is weird
k-logs-kubeapi:
	@kubectl -n kube-system logs -l k8s-app=kube-apiserver --tail=200

# Quick “is my env sane?” checklist
doctor:
	@echo "== AWS CLI version ==" && aws --version || true
	@echo "== Profile list ==" && aws configure list-profiles || true
	@echo "== Caller identity ==" && aws sts get-caller-identity || true
	@echo "== Terraform version ==" && terraform -version || true
	@echo "== TF providers ==" && $(TF) providers || true
	@echo "== kube context ==" && kubectl config current-context || true
	@echo "== kube user exec ==" && kubectl config view --minify -o jsonpath='{.users[0].user.exec.command}{" "}{.users[0].user.exec.args[*]}' ; echo || true

