<!-- markdownlint-configure-file {
  "MD013": {
    "code_blocks": false,
    "tables": false
  },
  "MD033": false,
  "MD041": false
} -->

<div align="center">

![pSync](.github/assets/psync_logo.png)

![GitHub release (with filter)](https://img.shields.io/github/v/release/lucasgolino/psync?label=last%20release)
![GitHub all releases](https://img.shields.io/github/downloads/lucasgolino/psync/total)
![GitHub Repo stars](https://img.shields.io/github/stars/lucasgolino/psync)


psync is a **easy postgres backup**, using Google Cloud Storage as vault.

It remembers which directories you use most frequently, so you can "jump" to
them in just a few keystrokes.

[Getting started](#getting-started) •
[Installation](#installation) •
[Usage](#usage)

</div>

---
# Getting started
Welcome to pSync, your trusted solution for scheduling PostgreSQL backups and sending them directly to Google Cloud Storage. We've designed pSync to be both powerful and user-friendly, ensuring that even users with minimal technical knowledge can get started in no time.

# Installation
Installation is a easy process, just run the following shell script in your terminal: install.sh

![install](.github/assets/install_terminal.png)

After that, you will have systemd service created and ready to run.
You can type: `systemctl status psync.timer` to check if it's running and `systemctl start psync.timer` to start it.

For single run, you need to add on your bash configuration file (e.g. ~/.bashrc) the following line (remember to fill with used path on installation):
```bash
PATH=$PATH:/opt/psync
```

# Usage
To use psync as standalone run, you need to create a configuration file on your home directory, named `psync.env` with the following content:

```env
export GOOGLE_APPLICATION_CREDENTIALS=</path/to/credential.json>

export PROJECT_ID=project_id>
export GCS_BUCKET_NAME=<gcs_bucket_name>

export PSQL_HOST=<postgres_host>
export PSQL_PORT=<postgres_port>
export PSQL_DBNAME=<postgres_dbname>
export PSQL_USER=<postgres_user>
export PSQL_PASSWORD=<postgres_password>
```

And finally, run the following commands:

```bash
$ source ./psync.env
$ psync
```