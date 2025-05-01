
# 🚀 up42 Assesment

This repository contains production-ready Helm charts and Kubernetes configuration for deploying:

- 📦 [`s3www`](https://github.com/raviusit/up42/s3www-app): a lightweight static file web server written in GO lang that serves content directly from an S3-compatible bucket.
- 🗄️ [`MinIO`](https://min.io/): high-performance, self-hosted, S3-compatible object storage service.

It is designed for cloud-native deployments using Helm and Kubernetes, with a focus on **reusability**, **security**, and **configurability**.

---

## 🧭 Project Structure

```
├── LICENSE
├── README.md
├── charts
│   ├── README.md
│   ├── main.tf
│   ├── minio
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── _helpers.tpl
│   │   │   ├── deployment.yaml
│   │   │   ├── hpa.yaml
│   │   │   ├── ingress.yaml
│   │   │   ├── pvc.yaml
│   │   │   ├── secret.yaml
│   │   │   ├── service.yaml
│   │   │   ├── upload-cronjob.yaml
│   │   │   └── upload-job.yaml
│   │   └── values.yaml
│   └── s3www
│       ├── Chart.yaml
│       ├── templates
│       │   ├── _helpers.tpl
│       │   ├── deployment.yaml
│       │   ├── hpa.yaml
│       │   ├── ingress.yaml
│       │   ├── service.yaml
│       │   ├── serviceMonitor.yaml
│       │   └── tls-secret.yaml
│       └── values.yaml
└── s3www-app
    ├── CNAME
    ├── CREDITS
    ├── Dockerfile
    ├── LICENSE
    ├── README.md
    ├── datatypes.go
    ├── go.mod
    ├── go.sum
    ├── main.go
    ├── object.go
    ├── s3www
    └── s3www.png
```

---

## 📦 Applications/Components

### 1. `s3www`

A minimal web server that serves static sites directly from MinIO buckets. It supports files browsing only, custom headers and not implemented here and it can be used in place of costly CDN services for simple web hosting.

### 2. `MinIO`

An S3-compatible, Kubernetes-native object store used in this setup as the backend for `s3www`.

---

## 🚀 Deployment Instructions

### ✅ Prerequisites

- Kubernetes cluster (A minikube or KIND Cluster* (Kubernetes in Docker)) v1.32 is used here.
- Helm 3.x+
- `kubectl` access to your cluster
- Ingress controller (e.g., NGINX)
- Prometheus  

---

## 🛠 Step-by-Step Deployment

### Setup any k8s cluster

I've chosen KIND Cluster (https://kind.sigs.k8s.io/docs/user/quick-start/), because I ran into an issue with minikube as I was running it on M1 pro. while testing application, the ingress not working on Mac M1 host machine

Issue - https://github.com/kubernetes/minikube/issues/13510
Resolution - https://medium.com/@sushantkumarsinha22/kubernetes-setting-up-ingress-on-apple-silicon-mac-m1-5fb6bddcb838

But then I realised I usually use kind setup for local testing and its very easy to set up.


```

kind create cluster --name=kindv1.32
OR
kind create cluster --config kind-example-config.yaml 
```

contents in the kind-example-config.yaml

``` bash
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

To Install Cluster with ingress (https://kind.sigs.k8s.io/docs/user/ingress/)
Choose Option 2: extraPortMapping

```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
# - role: worker
# - role: worker
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

```Note: this is a single node cluster, if you want multinode cluster then uncomment the lines for role
```

To apply ingress -

```bash
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

To install Prometheus - 

```bash
brew install helm  # macOS

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

```
This will install:
Prometheus
Alertmanager
Grafana
The Prometheus Operator
Node exporters, kube-state-metrics, and more.
```

Verify that pods are running - 
```bash
kubectl get pods -n monitoring
```

Accessing Prometheus/Grafana Dashboards
For local clusters like kind, expose them with port-forwarding:

Prometheus:
```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
```
Visit: http://localhost:9090

Grafana:
```bash
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
```
Visit: http://localhost:3000


Default Grafana login:

User: admin
Password: prom-operator (can be retrieved via secret)

```bash
kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

### 1. Clone this repository

```bash
git clone https://github.com/raviusit/up42.git
cd up42
```

### 1.1 Building s3www latest image

go to the /s3www-app folder

Since I'm still on M1 pro, the arch type (arm64) is different than where we are going to deploy this app (amd64)
So, use the commands to change the archtype, this will generate a Go binary named s3www -
```bash
GOOS=linux GOARCH=amd64 go build -o s3www .
docker buildx build --platform linux/amd64,linux/arm64 -t raviusit/s3www .
docker image tag raviusit/s3www raviusit/s3www:<image tag>
docker push raviusit/s3www:<image tag>
```

### 1.2 Update image tag in the s3wwww chart values.yaml

 /charts/s3www/values.yaml

```bash
image:
  repository: raviusit/s3www
  tag: <image tag>
```

### 2. Create namespaces

```bash
kubectl create namespace up42
```

---

### 3. Deploy minIO and s3www

```bash 
cd charts
terraform plan
terraform apply
```
---

### 5. Access Your Services

#### 📂 MinIO Console

```bash
kubectl port-forward svc/minio-minio 9001:9001 -n up42
```

Visit: [http://localhost:9001](http://localhost:9000)  
Login using credentials from `charts/minio/values.yaml`.

#### 🌍 s3www Site

The Ingress is enabled in `charts/s3www/values.yaml`, visit:

```
https://s3www.local
```

Or port-forward directly:

```bash
kubectl port-forward svc/s3www 8080:8080 -n up42
```

Then open: [http://localhost:8080](http://localhost:8080)

---

## 🧾 Example `charts/s3www/values.yaml`

```yaml
ireplicaCount: 1

image:
  repository: raviusit/s3www
  tag: 1.0.0
  pullPolicy: IfNotPresent

container:
  port: "8080"
  targetport: "8080"

args:
  - -bucket
  - s3www-static
  - -endpoint
  - http://minio-minio.up42.svc.cluster.local:9000

env:
  AWS_ACCESS_KEY_ID: minioadmin
  AWS_SECRET_ACCESS_KEY: minioadmin
  S3WWW_ADDRESS: 0.0.0.0:8080
```

---

## 🧾 Example `values/minio.yaml`

```yaml
eplicaCount: 1

image:
  repository: quay.io/minio/minio
  tag: latest
  pullPolicy: IfNotPresent

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

bucketName: s3www-static  # This is correct, it's at the root level

imagesToDownload:
  - https://media3.giphy.com/media/VdiQKDAguhDSi37gn1/giphy.gif
  - https://media3.giphy.com/media/7JjRCjPMplDWBkOAIP/giphy.gif
  - https://media1.giphy.com/media/vAvuIyU8lILMK7xD5B/giphy.gif

hpa:
  enabled: true
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 50

persistence:
  enabled: true
  accessMode: ReadWriteOnce
  size: 10Gi
  storageClass: ""

secret:
  name: minio-secret
  accessKey: minioadmin
  secretKey: minioadmin

service:
  type: ClusterIP
  ports:
    - name: api
      port: 9000
      targetPort: 9000
    - name: console
      port: 9001
      targetPort: 9001

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  hosts:
    - host: minio.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

```

---

## 🔒 Security & Production Tips

- Use secrets for credentials in production (`External Secrets`)
- Enable TLS using `cert-manager` or your Ingress provider
- Use MinIO buckets with versioning enabled
- Enable access logging on the s3www server
- Run multiple replicas for high availability (HPA already configured)

---

## 🔁 Cleanup

```bash
terraform destroy
```

---

## 📌 License

MIT – see [LICENSE](./LICENSE)

---

## 🤝 Contributing

PRs are welcome! Please raise an issue or fork the repo to contribute improvements.
