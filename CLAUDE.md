# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of utility shell scripts for automating common system administration and development tasks. The repository contains standalone bash scripts that can be executed individually, each with its own purpose and command-line interface.

## Script Categories

### Development Tool Installers
- `install_nvim` - Downloads and installs the latest or specified version of Neovim
- `install_zig` - Downloads and installs the latest or specified version of Zig programming language  
- `install_zls` - Installs Zig Language Server (requires Zig to be installed first)
- `install_go` - Go programming language installer
- `install_plex` - Plex Media Server installer with Plex Pass support

### System Utilities
- `fix_via_access` - Fixes udev rules for VIA keyboard configuration tool access
- `pg_s3_backup` - PostgreSQL database backup utility that uploads dumps to Amazon S3

### Git/GitHub Tools
- `init_gh_repo` - Comprehensive GitHub repository creation and setup script using gh CLI

## Script Architecture

All scripts follow these common patterns:

### Command Line Interface
- Use `--help` or `-h` for usage information
- Support both short (`-v`) and long (`--version`) option formats
- Parse arguments using case statements with parameter/value extraction
- Provide detailed usage functions with examples

### Error Handling
- Use `set -e` to exit on any command failure
- Include prerequisite checks (e.g., checking if required tools are installed)
- Validate required parameters before execution

### Version Management
- Query GitHub API or official sources for latest versions when version not specified
- Compare current installed versions to avoid unnecessary reinstalls
- Support force installation with `-f`/`--force` flags

## Common Usage Patterns

### Installation Scripts
```bash
./install_nvim --version=v0.9.0
./install_zig --force
./install_zls  # Automatically detects compatible Zig version
```

### Backup Script
```bash
./pg_s3_backup --host=localhost --dbname=mydb --s3-bucket=my-backups --aws-profile=production
```

### Repository Creation
```bash
./init_gh_repo --name=my-project --description="My new project" --private
```

## Dependencies

Scripts may require these external tools:
- `curl` - For API calls and downloads
- `jq` - For JSON parsing (GitHub API responses)
- `wget` - For file downloads
- `gh` - GitHub CLI (for init_gh_repo)
- AWS CLI (for S3 backup script)

## File Locations

- Temporary files: `/tmp/`
- Installation target: `/usr/local/bin/` (requires sudo)
- Configuration files: Script-specific locations