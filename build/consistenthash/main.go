package main

import (
	"fmt"

	"math/big"

	"github.com/alecthomas/kong"
	"github.com/buraksezer/consistent"
	"github.com/cespare/xxhash"
	"github.com/pkg/errors"
)

type CLI struct {
	Key  string   `arg:"" optional:"" help:"Key to hash to a data value" `
	Data []string `arg:"" optional:"" help:"Space-delimited list of possible data values"`
}

type hasher struct{}

func (h hasher) Sum64(data []byte) uint64 {
	// you should use a proper hash function for uniformity.
	return xxhash.Sum64(data)
}

type ringNode string

func (n ringNode) String() string {
	return string(n)
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

func nextPrime(n int) (int, error) {
	for i := n; i < 2*n; i++ {
		if big.NewInt(int64(i)).ProbablyPrime(0) {
			return i, nil
		}
	}
	return 0, errors.Errorf("could not find next prime after %d", n)
}

func getHash(nodes []string, key string) (string, error) {
	partitionCount, err := nextPrime(len(nodes) * 3)
	if err != nil {
		return "", err
	}

	cfg := consistent.Config{
		PartitionCount:    partitionCount,
		ReplicationFactor: partitionCount * 3,
		Load:              1.25,
		Hasher:            hasher{},
	}
	c := consistent.New(nil, cfg)
	for _, node := range nodes {
		c.Add(ringNode(node))
	}

	return c.LocateKey([]byte(key)).String(), nil
}
