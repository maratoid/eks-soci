package main

import (
	"fmt"

	"github.com/alecthomas/kong"
	"github.com/pkg/errors"
	"github.com/serialx/hashring"
)

type CLI struct {
	Key  string   `arg:"" optional:"" help:"Key to hash to a data value" `
	Data []string `arg:"" optional:"" help:"Space-delimited list of possible data values"`
}

func (c *CLI) Validate() error {
	if len(c.Key) == 0 {
		return errors.New("key is required")
	}

	if len(c.Data) == 0 {
		return errors.New("space-delimited list of data values is required")
	}

	res, err := getHash(c.Data, c.Key)
	if err != nil {
		return err
	}

	fmt.Println(res)
	return nil
}

func (c *CLI) Run() error {
	return nil
}

func main() {
	var cli CLI

	ctx := kong.Parse(&cli,
		kong.Name("consistenthash"),
		kong.Description(`Consistently hash <key> to one of the values in [data].`))

	_ = ctx.Run()
}

func getHash(nodes []string, key string) (string, error) {
	ring := hashring.New(nodes)
	x, ok := ring.GetNode(key)
	if !ok {
		return "", errors.Errorf("no node found for key %q", key)
	}
	return x, nil
}
