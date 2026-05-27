{{/*
Expand the name of the chart.
*/}}
{{- define "presidio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "presidio.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "presidio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "presidio.labels" -}}
helm.sh/chart: {{ include "presidio.chart" . }}
{{ include "presidio.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "presidio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "presidio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Multicluster deployment gating — presidio follows ai-gateway placement.
Deploy when ai-gateway would deploy locally on this cluster:
  - Single-cluster (multicluster disabled): always
  - Parent mode with aiGateway NOT remote in parent.groups: yes
  - Child mode with aiGateway enabled in child.groups: yes
Otherwise skip.
*/}}
{{- define "presidio.mc.isLocalDeploy" -}}
{{- $mc := (.Values.global).multicluster | default dict -}}
{{- if not ($mc.enabled | default false) -}}true
{{- else if eq ($mc.mode | default "parent") "child" -}}
  {{- if (index (($mc.child).groups | default dict) "aiGateway") -}}true{{- end -}}
{{- else -}}
  {{- $provider := index (($mc.parent).groups | default dict) "aiGateway" -}}
  {{- if not $provider -}}true{{- end -}}
{{- end -}}
{{- end -}}
