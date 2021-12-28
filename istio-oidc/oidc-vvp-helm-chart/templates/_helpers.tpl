{{- define "vvpWorkloadLabels" }}
{{- range $key, $value := .Values.vvpWorkloadLabels }}
{{- $key }}: {{ $value }}
{{- end }}
{{- end }}
