package psql

import (
	"fmt"
	pg "github.com/habx/pg-commands"
	"os"
	"strconv"
)

type Config struct {
	Host     string
	Port     int
	DBName   string
	User     string
	Password string
}

type Psql struct {
	Cfg Config
}

func NewDriver() *Psql {
	driver := Psql{}
	driver.config()

	return &driver
}

func (p *Psql) config() {
	var port int
	var err error
	var stringPort = os.Getenv("PSQL_PORT")

	if port, err = strconv.Atoi(stringPort); err != nil {
		port = 5432
	}

	p.Cfg = Config{
		Host:     os.Getenv("PSQL_HOST"),
		Port:     port,
		DBName:   os.Getenv("PSQL_DBNAME"),
		User:     os.Getenv("PSQL_USER"),
		Password: os.Getenv("PSQL_PASSWORD"),
	}
}

func (p *Psql) Get() (string, error) {
	dump, err := pg.NewDump(&pg.Postgres{
		Host:     p.Cfg.Host,
		Port:     p.Cfg.Port,
		DB:       p.Cfg.DBName,
		Username: p.Cfg.User,
		Password: p.Cfg.Password,
	})

	if err != nil {
		return "", fmt.Errorf("failed to create dump connection: %w", err)
	}

	dir := fmt.Sprintf("%s/", os.TempDir())
	dump.SetPath(dir)

	dumpExec := dump.Exec(pg.ExecOptions{
		StreamPrint: false,
	})

	if dumpExec.Error != nil {
		fmt.Printf("COMMAND: %s\n", dumpExec.FullCommand)
		fmt.Printf("ERROR: %s\n", dumpExec.Output)
		return "", fmt.Errorf("failed to dump database: %s", dumpExec.Error.Err)
	}

	fmt.Printf("Successfully dumped database %s\n", dumpExec.File)

	return fmt.Sprintf("%s%s", dir, dump.GetFileName()), nil
}
