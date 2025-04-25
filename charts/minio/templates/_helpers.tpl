{{/*
Generate the full name of the release.
*/}}
{{- define "minio.fullname" -}}
{{- .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{/*
Generate the name of the MinIO service.
*/}}
{{- define "minio.name" -}}
{{- .Chart.Name }}
{{- end -}}
