import '../../utils/utils.just'
{{- range (datasource "module").subcommands }}
import './{{ . }}.just'
{{- end }}

[private]
default:
  @just --justfile {{"{{"}} justfile() {{"}}"}} --list {{ (datasource "module").name }}