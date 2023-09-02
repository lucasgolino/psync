package psync

import (
	"cloud.google.com/go/storage"
	"context"
	"fmt"
	"io"
	"log"
)

type Psync struct {
	ctx    context.Context
	Bucket *storage.BucketHandle
}

func (p *Psync) Routine() {
	config := LoadConfig()
	p.ctx = context.Background()

	client, err := storage.NewClient(p.ctx)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()

	p.Bucket = client.Bucket(config.Bucket)
}

func (p *Psync) WriteFile(filename string, reader io.Reader) error {
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
