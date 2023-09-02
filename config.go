package psync

import (
	"os"
)

// Config struct
type Config struct {
	ProjectID string
	Bucket    string
}

func LoadConfig() Config {
	config := Config{
		ProjectID: os.Getenv("GCS_PROJECT_ID"),
		Bucket:    os.Getenv("GCS_BUCKET_NAME"),
	}

	return config
}
