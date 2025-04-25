provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "minio" {
  name       = "minio"
  chart      = "./minio-chart"
  namespace  = "default"
  create_namespace = true
  values     = [file("${path.module}/minio-chart/values.yaml")]
}
