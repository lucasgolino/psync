package main

import (
	"github.com/lucasgolino/psync"
	"os"
)

func main() {
	var psync psync.Psync

	f, err := os.Open("./samples/sample-10.file")
	if err != nil {
		panic("failed to read file")
	}
	defer f.Close()

	psync.Routine()
	if err = psync.WriteFile("test.txt", f); err != nil {
		panic("failed to write file")
	}
}
