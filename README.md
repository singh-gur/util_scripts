# Utility Scripts Collection

A comprehensive collection of Bash utility scripts for system administration, DevOps automation, and development environment setup.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Scripts Documentation](#scripts-documentation)
  - [PostgreSQL Management](#postgresql-management)
  - [Cloud & Storage](#cloud--storage)
  - [Kubernetes & DevOps](#kubernetes--devops)
  - [Development Tools](#development-tools)
  - [System Configuration](#system-configuration)
  - [Networking](#networking)
  - [Version Control](#version-control)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Contributing](#contributing)

## Overview

This repository contains standalone Bash scripts designed to automate common tasks across development, operations, and system administration workflows. Each script is self-contained and follows consistent coding patterns for reliability and maintainability.

**Key Features:**
- 🔒 Secure credential handling (AWS profiles, SSH keys, PostgreSQL passwords)
- 🎯 Comprehensive error handling and validation
- 📝 Detailed usage documentation with examples
- 🧹 Automatic cleanup of temporary files
- ⚙️ Flexible configuration options (both `--option=value` and `--option value` formats)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/util_scripts.git
cd util_scripts

# Make scripts executable
chmod +x *

# View help for any script
./script_name --help
```

## Scripts Documentation

### PostgreSQL Management

#### `pg_s3_backup`
Backup PostgreSQL databases to S3-compatible storage with compression support.

**Features:**
- Single database or full cluster backup (pg_dump / pg_dumpall)
- Optional gzip compression
- AWS S3 or S3-compatible endpoints (MinIO, Wasabi, etc.)
- Profile-based or inline AWS credentials

**Usage:**
```bash
# Backup single database to S3
./pg_s3_backup --bucket my-backups --dbname mydb

# Backup with compression to custom S3 endpoint
./pg_s3_backup --bucket my-backups --dbname mydb --compress \
  --aws-endpoint-url http://localhost:9000 \
  --aws-access-key-id AKIAXXXXXXXX \
  --aws-secret-key secretkey

# Backup all databases
./pg_s3_backup --bucket my-backups --all --prefix production/
```

#### `pg_s3_restore`
Restore PostgreSQL databases from S3 backups.

**Features:**
- Single database or cluster restore
- Automatic decompression of gzip files
- Optional database drop and recreate
- Same S3 compatibility as backup script

**Usage:**
```bash
# Restore single database from S3
./pg_s3_restore --bucket my-backups --key mydb-20231201_143000.sql.gz --dbname mydb

# Restore all databases
./pg_s3_restore --bucket my-backups --key all-20231201_143000.sql --all

# Restore with database drop
./pg_s3_restore --bucket my-backups --key backup.sql.gz --dbname mydb --drop-if-exists
```

#### `pg_create_db_user`
Create PostgreSQL databases with properly configured users and permissions.

**Features:**
- Automated database and user creation
- Three permission levels: minimal, standard, full
- Idempotent (safe to run multiple times)
- Password policy enforcement (minimum 8 characters)

**Usage:**
```bash
# Create database with standard permissions
./pg_create_db_user --dbname=myapp_db --username=myapp_user --password=SecurePass123

# Create with full privileges
./pg_create_db_user --dbname=myapp_db --username=myapp_user \
  --password=SecurePass123 --permission=full

# Test mode (check existence without creating)
./pg_create_db_user --dbname=myapp_db --username=myapp_user \
  --password=test --test-only
```

### Cloud & Storage

#### `s3_sync`
Sync data between local filesystem and S3 using AWS CLI.

**Features:**
- Bidirectional sync (upload/download)
- Incremental sync (only changed files)
- Include/exclude patterns
- Dry-run mode for testing
- Background execution with tmux
- Size-only or exact timestamp comparison

**Usage:**
```bash
# Upload local directory to S3
./s3_sync ./local_dir s3://my-bucket/remote_dir

# Download from S3 to local
./s3_sync s3://my-bucket/remote_dir ./local_backup --profile production

# Sync with delete (mirror mode)
./s3_sync ./data s3://bucket/data --delete --verbose

# Pattern-based sync
./s3_sync s3://bucket/data ./local --include "*.txt" --exclude "temp/*"

# Run in background tmux session
./s3_sync ./large_dir s3://bucket/backup --background
```

#### `mount_nas`
Mount NFS4 shares from NAS servers with automatic configuration.

**Features:**
- NFS4 protocol support
- Subdirectory mounting
- Automatic directory creation
- Force remount option
- Connectivity testing before mount

**Usage:**
```bash
# Mount base directory
./mount_nas

# Mount specific subdirectory
./mount_nas documents

# Custom server and paths
./mount_nas --server=192.168.1.100 --source-base=/data photos

# Force remount if already mounted
./mount_nas --force --verbose media
```

### Kubernetes & DevOps

#### `setup_local_k8s`
Automated Minikube cluster setup with ArgoCD for local Kubernetes development.

**Features:**
- Multi-node cluster support
- ArgoCD installation and configuration
- Git repository integration (SSH authentication)
- Automatic addon installation (ingress, metrics-server)
- Cluster info display with access credentials

**Usage:**
```bash
# Basic setup with defaults
./setup_local_k8s --ssh-key=~/.ssh/id_rsa

# Multi-node cluster with custom resources
./setup_local_k8s --nodes=3 --driver=kvm2 --memory=8192 --ssh-key=~/.ssh/id_rsa

# Custom repository and app path
./setup_local_k8s --repo=git@github.com:myorg/myrepo.git \
  --app-path=apps/dev --values=values_dev.yaml --ssh-key=~/.ssh/deploy_key

# Show existing cluster info
./setup_local_k8s --info

# Force recreate cluster
./setup_local_k8s --force --ssh-key=~/.ssh/id_rsa
```

### Development Tools

#### `install_go`
Install or update Go programming language.

**Usage:**
```bash
# Install latest version
./install_go

# Install specific version
./install_go --version=1.21.5

# Force reinstall
./install_go --version=1.21.5 --force
```

#### `install_nvim`
Install or update Neovim editor.

**Usage:**
```bash
# Install latest version
./install_nvim

# Install specific version
./install_nvim --version=v0.9.5

# Force reinstall
./install_nvim --version=v0.9.5 --force
```

#### `install_zig`
Install or update Zig programming language.

**Usage:**
```bash
# Install latest version
./install_zig

# Install specific version
./install_zig --version=0.11.0

# Force reinstall
./install_zig --version=0.11.0 --force
```

#### `install_zls`
Install Zig Language Server (requires Zig to be installed first).

**Usage:**
```bash
./install_zls
```

#### `install_plex`
Install Plex Media Server.

**Usage:**
```bash
# Install with Plex Pass token
./install_plex --token YOUR_PLEX_TOKEN

# Specify architecture and distro
./install_plex --token TOKEN --arch amd64 --distro debian
```

### System Configuration

#### `screen_config`
Configure multi-monitor setups for GNOME desktop (3 screens).

**Features:**
- Mirror mode (all screens same content)
- Extend-one mode (one extended, two mirrored)
- Extend-all mode (all screens side-by-side)
- Primary display selection
- Auto-detection of optimal resolutions
- Dry-run mode

**Usage:**
```bash
# Mirror all screens
./screen_config mirror

# Extend first screen, mirror other two
./screen_config extend-one --resolution=1920x1080@60

# Extend all screens side-by-side
./screen_config extend-all

# Set second monitor as primary
./screen_config extend-all --primary=1

# Preview without applying
./screen_config mirror --dry-run
```

#### `fix_via_access`
Fix Via keyboard configurator access permissions for Linux.

**Usage:**
```bash
./fix_via_access
```

### Networking

#### `ssh_proxy`
Interactive SSH connection manager with proxy/jump host support.

**Features:**
- Interactive host selection from ~/.ssh/config
- Automatic ProxyJump detection
- Manual proxy specification
- Host listing and validation

**Usage:**
```bash
# List available hosts
./ssh_proxy --list

# Interactive mode
./ssh_proxy

# Connect to specific host
./ssh_proxy --target=webserver

# Connect through proxy
./ssh_proxy --target=dbserver --proxy=bastion

# Verbose output
./ssh_proxy --target=app --verbose
```

### Version Control

#### `init_gh_repo`
Create and initialize GitHub repositories using the GitHub CLI.

**Features:**
- Automatic git initialization
- GitHub repository creation
- Basic .gitignore generation
- Initial commit and push
- Public/private repository support

**Usage:**
```bash
# Create public repository from current directory
./init_gh_repo

# Create with custom name and description
./init_gh_repo --name my-project --description "My awesome project"

# Create private repository
./init_gh_repo --name my-private-repo --private

# Custom remote name
./init_gh_repo --name my-repo --remote upstream
```

## Prerequisites

### Common Requirements
- Bash 4.0 or higher
- Standard GNU utilities (grep, awk, sed, etc.)

### Script-Specific Requirements

**PostgreSQL scripts:**
- `postgresql-client` (pg_dump, pg_dumpall, psql)
- `awscli` (for S3 operations)
- `gzip` (for compression)

**Kubernetes:**
- `minikube`
- `kubectl`
- `curl`

**Cloud/Storage:**
- `awscli` (configured with credentials or profiles)
- `nfs-common` (for NFS mounting)
- `tmux` (optional, for background sync)

**Development tools:**
- `wget` or `curl`
- `jq` (for JSON parsing)

**System tools:**
- `gnome-monitor-config` (for screen_config)
- `gh` (GitHub CLI, for init_gh_repo)

## Installation

### Option 1: Clone Repository
```bash
git clone https://github.com/yourusername/util_scripts.git
cd util_scripts
chmod +x *
```

### Option 2: Download Individual Scripts
```bash
# Download specific script
wget https://raw.githubusercontent.com/yourusername/util_scripts/main/script_name
chmod +x script_name
```

### Option 3: Add to PATH
```bash
# Add scripts directory to PATH
echo 'export PATH="$PATH:/path/to/util_scripts"' >> ~/.bashrc
source ~/.bashrc

# Now run scripts from anywhere
pg_s3_backup --help
```

## Usage Tips

### AWS Credentials
Scripts support two authentication methods:

1. **AWS Profile (recommended):**
   ```bash
   ./pg_s3_backup --bucket my-bucket --dbname mydb --aws-profile production
   ```

2. **Inline credentials:**
   ```bash
   ./pg_s3_backup --bucket my-bucket --dbname mydb \
     --aws-access-key-id AKIAXXXXXXXX \
     --aws-secret-key secretkey
   ```

### Dry Run Mode
Many scripts support `--dry-run` to preview actions:
```bash
./s3_sync ./data s3://bucket/backup --dry-run --verbose
./screen_config extend-all --dry-run
```

### Getting Help
Every script has comprehensive help:
```bash
./script_name --help
./script_name -h
```

## Contributing

### Code Style
All scripts follow consistent patterns documented in [AGENTS.md](AGENTS.md). Key guidelines:

- Use `set -e`, `set -u`, `set -o pipefail` for safety
- Quote all variable expansions
- Implement cleanup traps for temporary files
- Provide comprehensive usage documentation
- Support both `--option=value` and `--option value` formats
- Send errors to stderr with `>&2`

### Testing
Before submitting changes:
```bash
# Syntax check
bash -n script_name

# Shellcheck (if available)
shellcheck script_name

# Test help output
./script_name --help

# Test with dry-run (if supported)
./script_name --dry-run
```

## License

This project is provided as-is for educational and operational purposes.

## Author

Gurbakhshish Singh

## Support

For issues or questions:
- Open an issue on GitHub
- Check script help with `--help` flag
- Review [AGENTS.md](AGENTS.md) for coding guidelines
