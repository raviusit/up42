# MinIO Helm Chart with Terraform

This repository contains a Helm chart and Terraform configuration for deploying MinIO on a Kubernetes cluster, specifically tested with a local Kind cluster.

## 🧰 Prerequisites

- Docker
- [Kind](https://kind.sigs.k8s.io/)
- kubectl
- Helm
- Terraform

## 🚀 Getting Started

### 1. Create Kind Cluster

```bash
cat <<EOF | kind create cluster --name minio-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
EOF
```

### 2. Install Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=Ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
```

### 3. Add to Hosts File

```bash
echo "127.0.0.1 minio.local" | sudo tee -a /etc/hosts
```

### 4. Deploy using Terraform

```bash
terraform init
terraform apply
```

### 5. Access MinIO

Open in browser:

```
http://minio.local/
```

Login credentials:
- Access Key: `minioadmin`
- Secret Key: `minioadmin`

---

## 🛠️ Project Structure

- `minio-chart/`: Helm chart
- `main.tf`: Terraform config
- `.github/workflows/deploy.yaml`: GitHub Actions workflow

