# up42
demo app for UP42 challenge


tree
.
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
