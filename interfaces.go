package psync

type Driver interface {
	Get() (string, error)
}
