{{/*
Expand the name of the chart.
*/}}
{{- define "ai-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ai-gateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | lower | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride | lower }}
{{- if contains $name (.Release.Name | lower) }}
{{- .Release.Name | lower | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | lower | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ai-gateway.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "ai-gateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ai-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ai-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Multicluster helpers.
Mode is read from global.multicluster (passed by parent chart) or .Values.multicluster.
Uplink entry point is always read from .Values.multicluster.child.uplinkEntryPoint (local config).
*/}}

{{/*
ai-gateway.mc.isParentMode: true when multicluster is disabled or mode != "child".
*/}}
{{- define "ai-gateway.mc.isParentMode" -}}
{{- $mc := default .Values.multicluster ((.Values.global).multicluster) -}}
{{- if not $mc.enabled -}}true{{- else if ne $mc.mode "child" -}}true{{- end -}}
{{- end -}}

{{/*
ai-gateway.mc.isChildDeploy: true when in child mode and aiGateway group is enabled.
*/}}
{{- define "ai-gateway.mc.isChildDeploy" -}}
{{- $mc := default .Values.multicluster ((.Values.global).multicluster) -}}
{{- if and $mc.enabled (eq $mc.mode "child") -}}
  {{- if (index ($mc.child).groups "aiGateway") -}}true{{- end -}}
{{- end -}}
{{- end -}}

{{/*
ai-gateway.mc.isRemoteGroup: true when in parent multicluster mode and aiGateway group
has a non-empty provider name (meaning the ai-gateway runs on a remote child cluster).
*/}}
{{- define "ai-gateway.mc.isRemoteGroup" -}}
{{- $mc := default .Values.multicluster ((.Values.global).multicluster) -}}
{{- if and $mc.enabled (include "ai-gateway.mc.isParentMode" .) -}}
  {{- $provider := index ($mc.parent).groups "aiGateway" -}}
  {{- if $provider -}}true{{- end -}}
{{- end -}}
{{- end -}}

{{/*
ai-gateway.mc.isLocalDeploy: true when ai-gateway workloads should deploy on this cluster.
True when: (parent mode AND NOT remote) OR (child mode AND group enabled).
*/}}
{{- define "ai-gateway.mc.isLocalDeploy" -}}
{{- if include "ai-gateway.mc.isParentMode" . -}}
  {{- if not (include "ai-gateway.mc.isRemoteGroup" .) -}}true{{- end -}}
{{- else -}}
  {{- include "ai-gateway.mc.isChildDeploy" . -}}
{{- end -}}
{{- end -}}

{{/*
ai-gateway.mc.uplinkAnnotation: emits hub.traefik.io/router.uplinks annotation in child mode.
*/}}
{{- define "ai-gateway.mc.uplinkAnnotation" -}}
{{- if include "ai-gateway.mc.isChildDeploy" . -}}
  {{- $ep := .Values.multicluster.child.uplinkEntryPoint -}}
  {{- if $ep -}}hub.traefik.io/router.uplinks: {{ $ep | quote }}{{- end -}}
{{- end -}}
{{- end -}}

{{/*
ai-gateway.mc.routeMatch: returns the IngressRoute match expression.
Parent: Host(`{host}.{domain}`) && PathPrefix(`{path}`)
Child:  PathPrefix(`/{endpointName}{path}`)
Usage: {{ include "ai-gateway.mc.routeMatch" (dict "root" $ "host" "gemini" "endpointName" "gemini" "path" "/v1/chat/completions") }}
*/}}
{{- define "ai-gateway.mc.routeMatch" -}}
{{- if include "ai-gateway.mc.isChildDeploy" .root -}}
  {{- if .path -}}
PathPrefix(`/{{ .endpointName }}{{ .path }}`)
  {{- else -}}
PathPrefix(`/{{ .endpointName }}`)
  {{- end -}}
{{- else -}}
  {{- if .path -}}
Host(`{{ .host }}.{{ (.root.Values.global).domain | default .root.Values.domain }}`) && PathPrefix(`{{ .path }}`)
  {{- else -}}
Host(`{{ .host }}.{{ (.root.Values.global).domain | default .root.Values.domain }}`)
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
ai-gateway.mc.entryPoints: returns entryPoints block, or empty in child mode.
*/}}
{{- define "ai-gateway.mc.entryPoints" -}}
{{- if not (include "ai-gateway.mc.isChildDeploy" .) -}}
  {{- $eps := list -}}
  {{- range .Values.entryPoints -}}
    {{- $eps = append $eps (printf "  - %s" .) -}}
  {{- end -}}
  {{- printf "entryPoints:\n%s" (join "\n" $eps) -}}
{{- end -}}
{{- end -}}
