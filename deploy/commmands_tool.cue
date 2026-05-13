package cmd

import (
	"strings"
)

_namespace: string @tag(namespace)
_valueFiles: string @tag(values)
_valueFilesList: *strings.Split(_valueFiles, ",") | []
