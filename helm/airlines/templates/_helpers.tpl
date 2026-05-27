{{/*
Generate a deterministic Keycloak user ID from a username (matches keycloak chart's sha256sum-based UUID).
Usage: {{ include "airlines.keycloak.userId" "admin" }}
*/}}
{{- define "airlines.keycloak.userId" -}}
{{- $h := . | sha256sum -}}
{{- printf "%s-%s-%s-%s-%s" ($h | substr 0 8) ($h | substr 8 12) ($h | substr 12 16) ($h | substr 16 20) ($h | substr 20 32) -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "airlines.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "airlines.fullname" -}}
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
{{- define "airlines.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "airlines.labels" -}}
helm.sh/chart: {{ include "airlines.chart" . }}
{{ include "airlines.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "airlines.selectorLabels" -}}
app.kubernetes.io/name: {{ include "airlines.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Domain helper - returns "airlines.{global.domain}" as the service domain.
Pass global.domain as the base domain (e.g. "mysite.com"); airlines. prefix is added here.
*/}}
{{- define "airlines.domain" -}}
{{- $base := .Values.domain -}}
{{- if .Values.global -}}
  {{- if not (kindIs "invalid" .Values.global.domain) -}}
    {{- $base = .Values.global.domain -}}
  {{- end -}}
{{- end -}}
{{- printf "airlines.%s" $base }}
{{- end }}

{{/*
Port suffix helper - returns ":PORT" if global.port is set, else empty string.
*/}}
{{- define "airlines.portSuffix" -}}
{{- if .Values.global -}}
  {{- if .Values.global.port -}}
    {{- printf ":%v" .Values.global.port -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
Domain Match helper
*/}}
{{- define "airlines.domainMatch" -}}
{{- printf "Host(`%s`)" (include "airlines.domain" .) }}
{{- end }}

{{/*
Internal host-match helper.
In parent mode: returns Host(`{prefix}.airlines.{domain}`) with optional && PathPrefix(`/{version}`).
In child mode: returns PathPrefix(`/{prefix}/{version}`) or PathPrefix(`/{prefix}`).
Usage: {{ include "airlines.hostMatch" (dict "root" . "prefix" "flights") }}
       {{ include "airlines.hostMatch" (dict "root" . "prefix" "flights" "version" "v1") }}
*/}}
{{- define "airlines.hostMatch" -}}
{{- $mc := .root.Values.global.multicluster -}}
{{- if and $mc.enabled (eq $mc.mode "child") -}}
  {{- if .version -}}
PathPrefix(`/{{ .prefix }}/{{ .version }}`)
  {{- else -}}
PathPrefix(`/{{ .prefix }}`)
  {{- end -}}
{{- else -}}
  {{- if .version -}}
Host(`{{ .prefix }}.{{ include "airlines.domain" .root }}`) && PathPrefix(`/{{ .version }}`)
  {{- else -}}
Host(`{{ .prefix }}.{{ include "airlines.domain" .root }}`)
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Flights API
*/}}
{{- define "airlines.flights.apiUrl" -}}
https://flights.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.flights.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "flights") }}
{{- end }}

{{/*
Pricing API
*/}}
{{- define "airlines.pricing.apiUrl" -}}
https://pricing.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.pricing.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "pricing") }}
{{- end }}

{{/*
Bookings API
*/}}
{{- define "airlines.bookings.apiUrl" -}}
https://bookings.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.bookings.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "bookings") }}
{{- end }}

{{/*
Passengers API
*/}}
{{- define "airlines.passengers.apiUrl" -}}
https://passengers.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.passengers.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "passengers") }}
{{- end }}

{{/*
Check-in API
*/}}
{{- define "airlines.checkin.apiUrl" -}}
https://checkin.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.checkin.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "checkin") }}
{{- end }}

{{/*
Baggage API
*/}}
{{- define "airlines.baggage.apiUrl" -}}
https://baggage.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.baggage.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "baggage") }}
{{- end }}

{{/*
Crew API
*/}}
{{- define "airlines.crew.apiUrl" -}}
https://crew.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.crew.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "crew") }}
{{- end }}

{{/*
Notifications API
*/}}
{{- define "airlines.notifications.apiUrl" -}}
https://notifications.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.notifications.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "notifications") }}
{{- end }}

{{/*
Gates API
*/}}
{{- define "airlines.gates.apiUrl" -}}
https://gates.{{ include "airlines.domain" . }}
{{- end }}
{{- define "airlines.gates.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "gates") }}
{{- end }}

{{/*
MCP Server Host Matches
*/}}
{{- define "airlines.flightOpsMcp.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "flight-ops-mcp") }}
{{- end }}
{{- define "airlines.passengerSvcMcp.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "passenger-svc-mcp") }}
{{- end }}
{{- define "airlines.airportOpsMcp.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "airport-ops-mcp") }}
{{- end }}

{{/*
Test (Hoppscotch) Host Match
*/}}
{{- define "airlines.test.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "test") }}
{{- end }}

{{/*
Portal Host Match
*/}}
{{- define "airlines.portal.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "portal") }}
{{- end }}

{{/*
Dashboard Host Matches
*/}}
{{- define "airlines.board.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "board") }}
{{- end }}
{{- define "airlines.flightOpsDash.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "flight-ops") }}
{{- end }}
{{- define "airlines.passengerSvcDash.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "passenger-svc") }}
{{- end }}
{{- define "airlines.airportOpsDash.hostMatch" -}}
{{ include "airlines.hostMatch" (dict "root" . "prefix" "airport-ops") }}
{{- end }}

{{/*
OIDC URLs - derived from global.domain if not explicitly set.
Keycloak is at keycloak.{global.domain} (not under the airlines. subdomain).
*/}}
{{- define "airlines.oidc.issuerUrl" -}}
{{- if .Values.keycloak.oidc.issuerUrl -}}
{{- .Values.keycloak.oidc.issuerUrl -}}
{{- else -}}
{{- $base := .Values.global.domain | default .Values.domain -}}
{{- $port := include "airlines.portSuffix" . -}}
{{- printf "https://keycloak.%s%s/realms/traefik" $base $port -}}
{{- end -}}
{{- end }}
{{- define "airlines.oidc.jwksUrl" -}}
{{- include "airlines.oidc.issuerUrl" . }}/protocol/openid-connect/certs
{{- end }}
{{- define "airlines.oidc.clientId" -}}
{{- .Values.keycloak.oidc.clientId | default "traefik" -}}
{{- end }}
{{- define "airlines.oidc.clientSecret" -}}
{{- .Values.keycloak.oidc.clientSecret | default .Values.keycloak.realm.clientSecret | default "NoTgoLZpbrr5QvbNDIRIvmZOhe9wI0r0" -}}
{{- end }}

{{/*
Flask stateful service deployment template.
Creates: 2x ConfigMap (code + data) + Deployment + Service for a Python Flask CRUD service.
Service code is loaded from services/{name}_service.py + services/base_service.py.
Seed data is loaded from files/data/{name}.json.

Usage:
  non-versioned: {{ include "airlines.flaskService" (dict "root" . "name" "crew") }}
  versioned:     {{ include "airlines.flaskService" (dict "root" . "name" "flights" "versions" (list "v1" "v2")) }}

When `versions` is passed, the template mounts one ConfigMap per version at
/public/{version}/ (each ConfigMap expected to be named {name}-openapi-{version}),
matching base_service.py's per-version spec-serving behaviour. Without
`versions`, a single ConfigMap {name}-openapi is mounted at /public/.
*/}}
{{- define "airlines.flaskService" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .name }}-code
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}
data:
  base_service.py: |
{{ .root.Files.Get "services/base_service.py" | indent 4 }}
  service.py: |
{{ .root.Files.Get (printf "services/%s_service.py" .name) | indent 4 }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .name }}-data
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}
data:
  api.json: |
{{ .root.Files.Get (printf "files/data/%s.json" .name) | indent 4 }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .name }}-app
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .name }}-app
  template:
    metadata:
      labels:
        app: {{ .name }}-app
        component: {{ .name }}
    spec:
      initContainers:
        - name: install-deps
          image: python:3.11-slim
          command: ["pip", "install", "--quiet", "--target=/deps", "flask==3.0.0", "flask-cors==4.0.0"]
          volumeMounts:
            - name: deps
              mountPath: /deps
      containers:
        - name: flask
          image: python:3.11-slim
          command: ["python", "/app/service.py"]
          env:
            - name: PYTHONPATH
              value: /deps:/app
          ports:
            - containerPort: 3000
              name: http
          volumeMounts:
            - name: deps
              mountPath: /deps
            - name: code
              mountPath: /app
            - name: data
              mountPath: /api
            {{- if .versions }}
            {{- range $v := .versions }}
            - name: openapi-{{ $v }}
              mountPath: /public/{{ $v }}
            {{- end }}
            {{- else }}
            - name: openapi
              mountPath: /public
            {{- end }}
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              cpu: 200m
              memory: 256Mi
      volumes:
        - name: deps
          emptyDir: {}
        - name: code
          configMap:
            name: {{ .name }}-code
        - name: data
          configMap:
            name: {{ .name }}-data
        {{- if .versions }}
        {{- range $v := .versions }}
        - name: openapi-{{ $v }}
          configMap:
            name: {{ $.name }}-openapi-{{ $v }}
        {{- end }}
        {{- else }}
        - name: openapi
          configMap:
            name: {{ .name }}-openapi
        {{- end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}-app
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}
spec:
  type: ClusterIP
  ports:
    - port: 3000
      targetPort: 3000
      protocol: TCP
      name: http
  selector:
    app: {{ .name }}-app
{{- end -}}

{{/*
MCP Server deployment template.
Creates: ConfigMap (requirements.txt) + Deployment + Service for a Python FastMCP server.
The MCP code ConfigMap must be created separately (name: {name}-mcp-server).

Usage: {{ include "airlines.mcpService" (dict "root" . "name" "flight-ops") }}
*/}}
{{- define "airlines.mcpService" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .name }}-mcp-requirements
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}-mcp
data:
  requirements.txt: |
    mcp==1.22.0
    uvicorn>=0.32.1
    aiohttp==3.9.1
    anyio==4.11.0
    httpx>=0.27.0
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .name }}-mcp
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}-mcp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .name }}-mcp
  template:
    metadata:
      labels:
        app: {{ .name }}-mcp
        component: mcp
    spec:
      containers:
        - name: mcp-server
          image: python:3.11-slim
          ports:
            - containerPort: 8080
          command: ["/bin/sh", "-c"]
          args:
            - |
              pip install --no-cache-dir -r /app/requirements.txt && \
              python /app/main.py
          volumeMounts:
            - name: mcp-code
              mountPath: /app/main.py
              subPath: main.py
            - name: mcp-requirements
              mountPath: /app/requirements.txt
              subPath: requirements.txt
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
      volumes:
        - name: mcp-code
          configMap:
            name: {{ .name }}-mcp-server
        - name: mcp-requirements
          configMap:
            name: {{ .name }}-mcp-requirements
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}-mcp
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}-mcp
spec:
  type: ClusterIP
  ports:
    - port: 8080
      targetPort: 8080
      protocol: TCP
      name: mcp
  selector:
    app: {{ .name }}-mcp
{{- end -}}

{{/*
Dashboard deployment template.
Creates: Deployment + Service for an nginx dashboard instance.
Expects ConfigMaps created separately: {name}-nginx-conf, {name}-html.
Mounts the shared dashboard-shared-assets ConfigMap for JS/CSS.

Usage: {{ include "airlines.dashboardService" (dict "root" . "name" "flight-board") }}
*/}}
{{- define "airlines.dashboardService" -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .name }}
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ .name }}
  template:
    metadata:
      labels:
        app: {{ .name }}
        component: dashboard
    spec:
      initContainers:
        - name: build
          image: node:20-alpine
          env:
            - name: DASHBOARD
              value: {{ .name | trimSuffix "-dash" }}
          command:
            - sh
            - -c
            - |
              mkdir -p /workspace && \
              tar -xzf /src/src.tar.gz -C /workspace && \
              cd /workspace && \
              npm ci --prefer-offline && \
              npx vite build --outDir /tmp/dist && \
              cp /tmp/dist/assets/index.js /tmp/dist/assets/index.css /assets/
          volumeMounts:
            - name: build-src
              mountPath: /src
              readOnly: true
            - name: assets
              mountPath: /assets
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
            - name: assets
              mountPath: /usr/share/nginx/html/assets
            - name: nginx-conf
              mountPath: /etc/nginx/conf.d
      volumes:
        - name: html
          configMap:
            name: {{ .name }}-html
        - name: assets
          emptyDir: {}
        - name: build-src
          configMap:
            name: dashboard-build-src
        - name: nginx-conf
          configMap:
            name: {{ .name }}-nginx-conf
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  labels:
    {{- include "airlines.labels" .root | nindent 4 }}
    component: {{ .name }}
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
      name: http
  selector:
    app: {{ .name }}
{{- end -}}

{{/*
Multicluster helpers
*/}}

{{/*
airlines.mc.openApiPath: returns the openApiSpec path for an API/APIVersion.
  - Versioned APIs (version passed): /{prefix}/{version}/openapi.yaml — each
    APIVersion CRD points at its own spec file; the backend Flask app serves
    these side-by-side.
  - Non-versioned APIs (version empty): /{prefix}/openapi.yaml.
Usage:
  versioned:     {{ include "airlines.mc.openApiPath" (dict "prefix" "flights" "version" "v1") }}
  non-versioned: {{ include "airlines.mc.openApiPath" (dict "prefix" "crew") }}
*/}}
{{- define "airlines.mc.openApiPath" -}}
{{- if .version -}}
/{{ .prefix }}/{{ .version }}/openapi.yaml
{{- else -}}
/{{ .prefix }}/openapi.yaml
{{- end -}}
{{- end -}}

{{/*
airlines.mc.isParentMode: returns "true" if multicluster is disabled OR mode != "child".
Parent mode is the default — single-cluster deployments are always parent mode.
Usage: {{ if include "airlines.mc.isParentMode" . }}
*/}}
{{- define "airlines.mc.isParentMode" -}}
{{- $mc := .Values.global.multicluster -}}
{{- if not $mc.enabled -}}true{{- else if ne $mc.mode "child" -}}true{{- end -}}
{{- end -}}

{{/*
airlines.mc.isRemoteGroup: returns "true" when the named group is assigned to a remote provider.
Requires parent mode AND a non-empty provider name in multicluster.groups[group].
Usage: {{ include "airlines.mc.isRemoteGroup" (dict "root" . "group" "flightOps") }}
*/}}
{{- define "airlines.mc.isRemoteGroup" -}}
{{- $mc := .root.Values.global.multicluster -}}
{{- if include "airlines.mc.isParentMode" .root -}}
  {{- if $mc.enabled -}}
    {{- $provider := index $mc.parent.groups .group -}}
    {{- if $provider -}}true{{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
airlines.mc.isLocalDeploy: returns "true" when workloads should be deployed locally.
True when: (parent mode AND group is NOT remote) OR (child mode AND group is enabled).
Usage: {{ include "airlines.mc.isLocalDeploy" (dict "root" . "group" "flightOps") }}
*/}}
{{- define "airlines.mc.isLocalDeploy" -}}
{{- if include "airlines.mc.isParentMode" .root -}}
  {{- if not (include "airlines.mc.isRemoteGroup" (dict "root" .root "group" .group)) -}}true{{- end -}}
{{- else -}}
  {{- include "airlines.mc.isChildDeploy" (dict "root" .root "group" .group) -}}
{{- end -}}
{{- end -}}

{{/*
airlines.mc.isChildDeploy: returns "true" when running in child mode and the named group is enabled.
Usage: {{ include "airlines.mc.isChildDeploy" (dict "root" . "group" "flightOpsMcp") }}
*/}}
{{- define "airlines.mc.isChildDeploy" -}}
{{- $mc := .root.Values.global.multicluster -}}
{{- if and $mc.enabled (eq $mc.mode "child") -}}
  {{- if index $mc.child.groups .group -}}true{{- end -}}
{{- end -}}
{{- end -}}

{{/*
airlines.mc.uplinkAnnotation: emits the router.uplinks annotation line in child mode.
Returns empty string in parent mode. Use with nindent to append to existing annotations.
Usage: {{- include "airlines.mc.uplinkAnnotation" (dict "root" . "group" "flightOps") | nindent 4 }}
*/}}
{{- define "airlines.mc.uplinkAnnotation" -}}
{{- $mc := .root.Values.global.multicluster -}}
{{- if and $mc.enabled (eq $mc.mode "child") -}}
  {{- $ep := index $mc.child.uplinkEntryPoints .group -}}
  {{- if $ep -}}hub.traefik.io/router.uplinks: {{ $ep | quote }}{{- end -}}
{{- end -}}
{{- end -}}

{{/*
airlines.mc.entryPoints: returns the full entryPoints: YAML block, or empty in child mode.
Non-root uplink routers (child mode) cannot have entryPoints configuration in Traefik Hub.
In parent mode returns the full block using .Values.entryPoints.
Usage: {{- include "airlines.mc.entryPoints" (dict "root" . "group" "flightOps") | nindent 2 }}
*/}}
{{- define "airlines.mc.entryPoints" -}}
{{- $mc := .root.Values.global.multicluster -}}
{{- if not (and $mc.enabled (eq $mc.mode "child")) -}}
  {{- $eps := list -}}
  {{- range .root.Values.entryPoints -}}
    {{- $eps = append $eps (printf "  - %s" .) -}}
  {{- end -}}
  {{- printf "entryPoints:\n%s" (join "\n" $eps) -}}
{{- end -}}
{{- end -}}

{{/*
airlines.mc.parentRefs: emits parentRefs block for child MC multi-layer routing.
Usage: {{- include "airlines.mc.parentRefs" (dict "root" . "name" "flights-prefix-router") | nindent 2 }}
*/}}
{{- define "airlines.mc.parentRefs" -}}
{{- $mc := .root.Values.global.multicluster -}}
{{- if and $mc.enabled (eq $mc.mode "child") -}}
parentRefs:
  - name: {{ .name }}
    namespace: {{ .root.Release.Namespace }}
{{- end -}}
{{- end -}}

{{/*
airlines.mc.serviceSpec: returns the services list entry for an IngressRoute.
  - Parent + remote group + haName set: references the *-ha WRR TraefikService
    (the WRR does its own local/remote leg selection and version stripping).
  - Parent + remote group + haName empty: references the remote uplink
    @multicluster directly. Version stripping, if needed, happens on the child.
  - All other cases (local parent, child with local group): references the local
    Kubernetes service. For versioned APIs the caller passes `versionMiddleware`
    (e.g. "strip-version-v1") which is emitted at the service level to strip the
    version prefix before the request hits the backend. `services[].middlewares`
    works for K8s Service refs (Traefik wraps them in a generated load-balancer
    service with the middleware attached).
Usage:
  versioned:   include "airlines.mc.serviceSpec" (dict "root" . "svcName" "flights-app" "port" 3000 "group" "flightOps" "haName" "flights-ha" "versionMiddleware" "strip-version-v1")
  unversioned: include "airlines.mc.serviceSpec" (dict "root" . "svcName" "crew-app"    "port" 3000 "group" "flightOps" "haName" "")
*/}}
{{- define "airlines.mc.serviceSpec" -}}
{{- $mc := .root.Values.global.multicluster -}}
{{- $isRemote := include "airlines.mc.isRemoteGroup" (dict "root" .root "group" .group) -}}
{{- if and $isRemote .haName -}}
- kind: TraefikService
  name: {{ .haName }}
{{- else if $isRemote -}}
  {{- $ep := index $mc.child.uplinkEntryPoints .group -}}
- kind: TraefikService
  name: {{ $ep }}@multicluster
{{- else -}}
- name: {{ .svcName }}
  port: {{ .port }}
  passHostHeader: true
  {{- if .versionMiddleware }}
  middlewares:
    - name: {{ .versionMiddleware }}
  {{- end }}
{{- end -}}
{{- end -}}
