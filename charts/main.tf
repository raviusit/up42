terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "minio" {
  name       = "minio"
  namespace  = "up42"
  chart      = "./minio"
  values = [
    file("./minio/values.yaml")
  ]
}

resource "helm_release" "s3www" {
  name       = "s3www"
  namespace  = "up42"
  chart      = "./s3www"
  values = [
    file("./s3www/values.yaml")
  ]
}
