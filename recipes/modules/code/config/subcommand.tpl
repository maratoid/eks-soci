# Fill out {{ (datasource "subcommand").name }} synopsis doc string
{{ (datasource "subcommand").name }} {{- range (datasource "subcommand").params -}}{{" "}}{{ . }}{{- end -}}:
  #!{{"{{"}} shebang {{"}}"}}
  echo "Implement me!"