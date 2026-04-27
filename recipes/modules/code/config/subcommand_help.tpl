# {{ (datasource "subcommand").parent }} {{ (datasource "subcommand").name }} help page

# NAME

{{ (datasource "subcommand").parent }} {{ (datasource "subcommand").name }} {{- range (datasource "subcommand").params -}}{{" "}}[{{ . }}]{{- end}}

# DESCRIPTION

TODO: Add description here

# EXAMPLE

```zsh
just {{ (datasource "subcommand").parent }} {{ (datasource "subcommand").name }} ...
Fill me out!
```

# PARAMETERS

{{ if (gt ((datasource "subcommand").params | len) 0) }}
## Overview

TODO: add command parameter overview here

{{range (datasource "subcommand").params }}
## {{ . }}

TODO: documentation for {{ . }} parameter

{{ end }}
{{ else }}
None
{{ end }}

# FILES

TODO: related file locations or 'None'!

# Environment variables

TODO: related environment variables or 'None'!

# SEE ALSO

```zsh
TODO: related commands of note
```

# AUTHOR

[Your Name](mailto:you@domain.com)