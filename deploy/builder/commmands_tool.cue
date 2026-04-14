package cmd

import (
	"encoding/json"
)

_valueFiles: string @tag(values)
_valueFilesList: *json.Unmarshal(_valueFiles) | []
