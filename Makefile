.PHONY: help build-backend build-frontend build-all apply delete status logs

# Variables
REGISTRY ?= local
TAG ?= latest

help:
	@echo "Usage:"
	@echo "  make build-all      - Build Docker images for backend and frontend"
	@echo "  make apply          - Apply all Kubernetes manifests"
	@echo "  make delete         - Delete Kubernetes resources from the cluster"
	@echo "  make status         - Check the status of pods and services"
	@echo "  make logs-backend   - Tail logs from the backend pods"

build-backend:
	@echo "==> Building backend image (FastAPI + uv)..."
	docker build -t $(REGISTRY)/container-platform-backend:$(TAG) apps/backend/

build-frontend:
	@echo "==> Building frontend image (Nginx)..."
	docker build -t $(REGISTRY)/container-platform-frontend:$(TAG) apps/frontend/

build-all: build-backend build-frontend

apply:
	@echo "==> Applying Kubernetes manifests..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/secrets.yaml
	kubectl apply -f k8s/database/
	kubectl apply -f k8s/backend/
	kubectl apply -f k8s/frontend/
	kubectl apply -f k8s/ingress.yaml
	@echo "==> Done! Run 'make status' to monitor startup."

delete:
	@echo "==> Cleaning up Kubernetes resources..."
	kubectl delete -f k8s/ingress.yaml --ignore-not-found
	kubectl delete -f k8s/frontend/ --ignore-not-found
	kubectl delete -f k8s/backend/ --ignore-not-found
	kubectl delete -f k8s/database/ --ignore-not-found
	kubectl delete -f k8s/secrets.yaml --ignore-not-found
	kubectl delete -f k8s/configmap.yaml --ignore-not-found
	kubectl delete -f k8s/namespace.yaml --ignore-not-found

status:
	@echo "==> Pods Status:"
	kubectl get pods -n container-platform
	@echo ""
	@echo "==> Services Status:"
	kubectl get svc -n container-platform

logs-backend:
	kubectl logs -l app=backend -n container-platform --tail=50 -f