package psync

import (
	"cloud.google.com/go/storage"
	"context"
	"fmt"
	"github.com/lucasgolino/psync/config"
	"io"
	"log"
	"os"
	"time"
)

func NewRoutine(config config.Config, driver Driver) *Runner {
	return &Runner{
		Driver: driver,
		Config: config,
		ctx:    context.Background(),
	}
}

type Runner struct {
	ctx    context.Context
	Bucket *storage.BucketHandle
	Config config.Config

	Driver Driver
}

func (p *Runner) Run() error {
	client, err := storage.NewClient(p.ctx)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()

	p.Bucket = client.Bucket(p.Config.Bucket)

	fullFilePath, err := p.Driver.Get()
	if err != nil {
		fmt.Printf("failed: %v", err)
		return err
	}

	r, err := os.Open(fullFilePath)
	if err != nil {
		fmt.Printf("failed to openfile: %v", err)
		return err
	}
	defer r.Close()

	if err = p.SyncFile(p.genFileName(), r); err != nil {
		return err
	}

	return nil
}

func (p *Runner) genFileName() string {
	date := time.Now()
	return fmt.Sprintf("psync_%d_%d_%d_%d_%d_%d.sql.tar.gz", date.Year(), date.Month(), date.Day(), date.Hour(), date.Minute(), date.Second())
}

func (p *Runner) SyncFile(filename string, reader io.Reader) error {
	var obj = p.Bucket.Object(filename)
	var writer = obj.NewWriter(p.ctx)

	if _, err := io.Copy(writer, reader); err != nil {
		return fmt.Errorf("failed to copy file into bucket: %w", err)
	}

	if err := writer.Close(); err != nil {
		return fmt.Errorf("failed to close bucket writer: %w", err)
	}

	fmt.Printf("Successfully uploaded %q\n", filename)

	return nil
}
