#!/bin/bash
set -e

KUBECTL_VERSION="v1.30.0"
MINIKUBE_VERSION="v1.32.0"
ARGOCD_VERSION="v2.11.0"
CRICTL_VERSION="v1.28.0"

echo "📦 [1/9] Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y curl apt-transport-https ca-certificates gnupg git docker.io conntrack socat

echo "🐳 [2/9] Enabling Docker..."
sudo usermod -aG docker vagrant
sudo systemctl enable docker
sudo systemctl start docker

echo "📥 [3/9] Installing kubectl $KUBECTL_VERSION..."
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

echo "📥 [4/9] Installing Minikube $MINIKUBE_VERSION..."
curl -LO "https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64"
chmod +x minikube-linux-amd64 && sudo mv minikube-linux-amd64 /usr/local/bin/minikube

echo "📥 [5/9] Installing crictl $CRICTL_VERSION..."
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin
rm crictl-${CRICTL_VERSION}-linux-amd64.tar.gz

echo "📁 [6/9] Creating safe kube paths (avoid chown issues)..."
sudo mkdir -p /opt/minikube/kube
sudo mkdir -p /opt/minikube/data
sudo chown -R vagrant:vagrant /opt/minikube

# Export kubeconfig globally for vagrant user
echo 'export KUBECONFIG=/opt/minikube/kube/config' >> /home/vagrant/.bashrc
echo 'export MINIKUBE_HOME=/opt/minikube/data' >> /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc

echo "🚀 [7/9] Starting Minikube with Docker driver (safe config)..."
sudo -u vagrant bash <<EOF
export KUBECONFIG=/opt/minikube/kube/config
export MINIKUBE_HOME=/opt/minikube/data
minikube start --driver=docker --force
EOF

echo "📦 [8/9] Installing Argo CD..."
KUBECONFIG=/opt/minikube/kube/config kubectl create namespace argocd || true
KUBECONFIG=/opt/minikube/kube/config kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "📥 [9/9] Installing Argo CD CLI..."
curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
chmod +x argocd && sudo mv argocd /usr/local/bin/

echo "✅ DONE! Minikube (Docker) with Argo CD is up."
echo "👉 You can now run 'kubectl get nodes' after 'vagrant ssh'"
