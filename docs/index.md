# cronned-rclone 
[![Test image](https://github.com/adnanjaw/cronned-rclone/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/adnanjaw/cronned-rclone/actions/workflows/test.yml) |
[![Release image](https://github.com/adnanjaw/cronned-rclone/actions/workflows/release.yml/badge.svg)](https://github.com/adnanjaw/cronned-rclone/actions/workflows/release.yml)

A lightweight container tool that wraps Rclone with cron jobs using Ofelia. Easily schedule Rclone commands with
flexible cron expressions via INI-style configurations or Docker labels, while utilizing all standard Rclone commands.

---

## Features

- **Rclone Integration**: Leverage the powerful [Rclone](https://rclone.org/) for cloud operations (sync, copy, move,
  etc.).
- **Ofelia Scheduler**: Schedule tasks easily with [Ofelia](https://github.com/mcuadros/ofelia) and cron jobs.
