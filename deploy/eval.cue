package cmd

import (
	"maratg.com/buildkit/objects"
	val "maratg.com/buildkit/values"
)

inputValues: val.#Values
output: (objects.#MakeObjects & {values: inputValues}).objectsList
