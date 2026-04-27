package cmd

import (
	"strings"
)

_valueFiles: string @tag(values)
_valueFilesList: *strings.Split(_valueFiles, ",") | []
