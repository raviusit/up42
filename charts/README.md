# S3www and MinIO Helm Chart with Terraform

This repository contains a Helm chart and Terraform configuration for deploying S3www and MinIO on a Kubernetes cluster, specifically tested with a local Kind cluster.

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
echo "127.0.0.1 s3www.local" | sudo tee -a /etc/hosts
```

### 4. Deploy using Terraform

```bash
terraform init
terraform plan
terraform apply
```

### 5. Access s3www

Open in browser:

```
http://s3www.local/
```

Login credentials:
- Access Key: `minioadmin`
- Secret Key: `minioadmin`


### 5. Access minio

kubectl port-forward svc/minio-minio 9001:9001 -n up42

Open in browser:

```
http://localhost:9001/
```

Login credentials:
- Access Key: `minioadmin`
- Secret Key: `minioadmin`

---

## 🛠️ Project Structure

- `charts/minio`: Helm chart
- `charts/s3www`: Helm chart
- `main.tf`: Terraform config
- `.github/workflows/deploy.yaml`: GitHub Actions workflow

