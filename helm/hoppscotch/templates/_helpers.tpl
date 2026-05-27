{{/*
Effective hostname: explicit host > subdomain.global.domain
*/}}
{{- define "hoppscotch.host" -}}
{{- if .Values.host -}}
{{- .Values.host -}}
{{- else -}}
{{- printf "%s.%s" .Values.subdomain .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "hoppscotch.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: hoppscotch
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
