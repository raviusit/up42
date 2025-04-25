
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

---

## 🛠 Step-by-Step Deployment

### 1. Clone this repository

```bash
git clone https://github.com/raviusit/up42.git
cd up42
```

### 2. Create namespaces

```bash
kubectl create namespace up42
```

---

### 3. Deploy MinIO

Install MinIO with values:

```bash
cd charts
helm  --install minio charts/minio -n up42
```

> This installs MinIO with S3 access keys, and readiness for external access via Ingress.

---

### 4. Deploy s3www

Install the custom `s3www` chart:

```bash
helm --install s3www charts/s3www  -n up42
```

---

### 5. Access Your Services

#### 📂 MinIO Console

```bash
kubectl port-forward svc/minio-minio 9000:9000 -n up42
```

Visit: [http://localhost:9000](http://localhost:9000)  
Login using credentials from `charts/minio/values.yaml`.

#### 🌍 s3www Site

The Ingress is enabled in `charts/s3www/values.yaml`, visit:

```
http://s3www.local
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

- Use secrets for credentials in production (`SealedSecrets` or `External Secrets`)
- Enable TLS using `cert-manager` or your Ingress provider
- Use MinIO buckets with versioning enabled
- Enable access logging on the s3www server
- Run multiple replicas for high availability (HPA already configured)

---

## 🔁 Cleanup

```bash
helm uninstall s3www -n up42
helm uninstall minio -n up42
kubectl delete namespace up42
```

---

## 📌 License

MIT – see [LICENSE](./LICENSE)

---

## 🤝 Contributing

PRs are welcome! Please raise an issue or fork the repo to contribute improvements.
