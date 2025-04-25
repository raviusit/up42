{{/*
Generate the full name of the release.
*/}}
{{- define "s3www.fullname" -}}
{{- .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{/*
Generate the name of the s3www service.
*/}}
{{- define "s3www.name" -}}
{{- .Chart.Name }}
{{- end -}}
