package main

import (
	"github.com/lucasgolino/psync"
	"github.com/lucasgolino/psync/config"
	"github.com/lucasgolino/psync/drivers/psql"
)

func main() {
	cfg := config.Load()

	driver := psql.NewDriver()
	run := psync.NewRoutine(cfg, driver)

	run.Run()
}
