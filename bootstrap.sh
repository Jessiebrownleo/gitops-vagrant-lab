#!/bin/bash
set -e

# Install dependencies
sudo apt-get update
sudo apt-get install -y curl apt-transport-https ca-certificates gnupg git

# Install Docker
sudo apt-get install -y docker.io
sudo usermod -aG docker vagrant

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64 && sudo mv minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
sudo minikube start --driver=docker --force

# Enable ingress for Argo CD (optional)
sudo minikube addons enable ingress

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Argo CD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd-linux-amd64 && sudo mv argocd-linux-amd64 /usr/local/bin/argocd

echo "✔️ Bootstrap complete. Run 'vagrant ssh' to get inside the VM."
