{{/*
Expand the name of the chart.
*/}}
{{- define "eks-soci-builder.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eks-soci-builder.fullname" -}}
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
Create a default service account name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "eks-soci-builder.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "eks-soci-builder.fullname" . }}-serviceaccount
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eks-soci-builder.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eks-soci-builder.labels" -}}
helm.sh/chart: {{ include "eks-soci-builder.chart" . }}
{{ include "eks-soci-builder.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.labels }}
{{- toYaml .Values.labels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eks-soci-builder.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eks-soci-builder.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "eks-soci-builder.annotations" -}}
{{- if .Values.annotations }}
{{- toYaml .Values.annotations }}
{{- end }}
{{- end -}}

{{/*
Create disabled plugins toml array
*/}}
{{- define "eks-soci-builder.disabledContainerdPlugins" }}
{{- tpl "{{- range $_, $plugin := .Values.config.containerd.disabledPlugins }}{{ $plugin | quote }}, {{- end }}" . | trimSuffix "," }}
{{- end }}
