# AGENTS.md - Coding Guidelines for util_scripts

This document provides guidelines for AI coding agents working in this repository.

## Repository Overview

This is a collection of Bash utility scripts for system administration, DevOps, and automation tasks including:
- PostgreSQL backup/restore to S3
- NAS/NFS mounting utilities
- Kubernetes/Minikube setup with ArgoCD
- GitHub repository initialization
- Language tooling installation (Go, Zig, Neovim)
- SSH proxy/jump host management
- S3 synchronization utilities

## Build/Lint/Test Commands

### No Build System
This repository contains standalone Bash scripts with no build process. Scripts are executed directly.

### Running Scripts
```bash
# Make script executable (if needed)
chmod +x script_name

# Execute directly
./script_name [options]

# Or with bash
bash script_name [options]
```

### Testing Individual Scripts
```bash
# Syntax check
bash -n script_name

# Dry run (if script supports it)
./script_name --help
./script_name --dry-run  # for scripts that support this flag

# Test specific script examples:
./pg_s3_backup --help
./mount_nas --help
./s3_sync --dry-run ./test s3://bucket/test
```

### Validation
```bash
# Check shell syntax for all scripts
for script in *; do
  [[ -x "$script" && -f "$script" ]] && bash -n "$script" && echo "✓ $script"
done

# Use shellcheck if available (recommended)
shellcheck script_name
shellcheck pg_s3_backup mount_nas setup_local_k8s
```

## Code Style Guidelines

### Shell Script Standards

#### Shebang and Shell Options
- **Always** use `#!/bin/bash` as the shebang (line 1)
- **Always** include safety flags early in the script:
  ```bash
  set -e          # Exit on error
  set -u          # Exit on undefined variable (optional, use in most scripts)
  set -o pipefail # Exit on pipe failures
  ```
- Alternative verbose mode: `set +v` (use when you want to suppress verbose output)

#### Variable Naming
- Use **UPPERCASE** for global configuration variables and constants
  ```bash
  HOST="localhost"
  PORT="5432"
  AWS_REGION="us-east-1"
  CLEANUP_FILES=()
  ```
- Use **lowercase** for local function variables
  ```bash
  local exit_code=$?
  local file_size=$(du -h "$file")
  ```
- Use descriptive names: `SOURCE_BASE` not `SB`, `TARGET_PATH` not `TP`

#### Quoting
- **Always** quote variable expansions: `"$VAR"` not `$VAR`
- Quote paths that may contain spaces: `"$TARGET_PATH"` `"$SSH_KEY"`
- Exception: Arrays and word splitting when intentional

#### Functions

**Function Declaration Style:**
```bash
# Preferred style (seen in most scripts)
function_name() {
    local param1="$1"
    local param2="$2"
    
    # function body
}

# Alternative (less common)
function function_name() {
    # function body
}
```

**Function Organization:**
1. Helper/utility functions first
2. Validation functions
3. Core business logic functions
4. Main function last

**Common Function Patterns:**
```bash
# Validation function
validate_dependencies() {
    local missing_deps=()
    
    if ! command -v tool_name >/dev/null 2>&1; then
        missing_deps+=("package-name")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Error: Missing required dependencies: ${missing_deps[*]}" >&2
        exit 1
    fi
}

# Usage/help function
usage() {
    cat << EOF
usage: script_name [options]

Required:
  --param VALUE    Description

Optional:
  -h, --help       Show this help message

Examples:
  $0 --param value
EOF
}

# Cleanup trap
cleanup() {
    local exit_code=$?
    echo "Cleaning up..."
    # cleanup logic
    exit $exit_code
}

trap cleanup EXIT
```

#### Argument Parsing

**Standard Pattern with Both Formats (= and space):**
```bash
while [[ $# -gt 0 ]]; do
    case $1 in
        --option)
            OPTION="$2"
            shift 2
            ;;
        --option=*)
            OPTION="${1#*=}"
            shift
            ;;
        -o|--option-short)
            VALUE="$2"
            shift 2
            ;;
        -o=*|--option-short=*)
            VALUE="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done
```

**Alternative Pattern (= only):**
```bash
while [ "$1" != "" ]; do
    PARAM=$(echo $1 | awk -F= '{print $1}')
    VALUE=$(echo $1 | awk -F= '{print $2}')
    case $PARAM in
        -v | --version )
            VERSION=$(echo $VALUE | tr -d '"')
        ;;
        -h | --help )
            usage
            exit
    esac
    shift
done
```

#### Conditionals

**Prefer `[[ ]]` over `[ ]`:**
```bash
# Good
if [[ -z "$VAR" ]]; then
    echo "empty"
fi

if [[ "$VAR" == "value" ]]; then
    # do something
fi

# File tests
if [[ -f "$file" ]]; then
if [[ -d "$dir" ]]; then
if [[ ! -w "$path" ]]; then
```

**Command existence checks:**
```bash
if ! command -v tool_name &> /dev/null; then
    echo "Error: tool_name is not installed"
    exit 1
fi
```

#### Error Handling

**Standard Error Pattern:**
```bash
# Always send errors to stderr
echo "Error: message" >&2
exit 1

# Check command success
if ! some_command; then
    echo "Error: Command failed" >&2
    exit 1
fi

# Alternative with explicit check
some_command
if [ $? -ne 0 ]; then
    echo "Error: Command failed" >&2
    exit 1
fi
```

**Cleanup Handlers:**
```bash
CLEANUP_FILES=()

cleanup() {
    local exit_code=$?
    echo "Cleaning up temporary files..."
    for file in "${CLEANUP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
            echo "Removed: $file"
        fi
    done
    exit $exit_code
}

trap cleanup EXIT

# Add files to cleanup list
CLEANUP_FILES+=("$temp_file")
```

#### Output and Logging

**Echo statements:**
```bash
# Informational output
echo "Starting process..."
echo "Configuration:"
echo "  Option: $VALUE"

# Errors to stderr
echo "Error: Something went wrong" >&2

# Verbose mode
if [[ -n "$VERBOSE" ]]; then
    echo "Verbose information"
fi
```

**Here Documents for Multi-line Output:**
```bash
cat << EOF
Multi-line
output
here
EOF

# With variable substitution disabled
cat << 'EOF'
No $variable substitution
EOF
```

#### AWS CLI Patterns

**Authentication:**
```bash
# Support both profile and inline credentials
if [[ -n "$AWS_ACCESS_KEY_ID" ]]; then
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
    export AWS_DEFAULT_REGION="$AWS_REGION"
    aws s3 command...
else
    aws s3 command --profile "$AWS_PROFILE"
fi

# With endpoint URL support
if [[ -n "$AWS_ENDPOINT_URL" ]]; then
    aws s3 command --endpoint-url "$AWS_ENDPOINT_URL"
fi
```

#### Path Handling

**Tilde expansion:**
```bash
# Expand ~ to $HOME
TARGET_BASE="${TARGET_BASE/#\~/$HOME}"
SSH_KEY="${SSH_KEY/#\~/$HOME}"
```

**Path validation:**
```bash
if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
fi

if [[ ! -w "$dir" ]]; then
    echo "Error: Directory is not writable: $dir" >&2
    exit 1
fi
```

## Documentation Standards

### Help/Usage Messages
- Every script **must** have a `usage()` function
- Include clear description of purpose
- List all required and optional parameters
- Provide realistic examples
- Show default values where applicable

### Comments
- Comment complex logic and non-obvious operations
- Document why, not what (code shows what)
- Keep comments concise and up-to-date

## Best Practices

1. **Fail Fast**: Use `set -e` and validate inputs early
2. **Be Explicit**: Quote variables, use full test syntax `[[ ]]`
3. **Clean Up**: Use trap handlers for temporary files
4. **User Friendly**: Provide helpful error messages and usage examples
5. **Portable**: Stick to bash built-ins where possible
6. **Consistent**: Follow the existing patterns in the codebase
7. **Security**: Never echo passwords, handle credentials carefully
8. **Validation**: Check dependencies, validate inputs, test connectivity

## Common Patterns to Follow

- **Always** include a usage/help function with `--help` flag
- **Always** validate required dependencies
- **Always** validate required parameters
- **Always** provide clear error messages to stderr
- **Prefer** functions over inline code for reusability
- **Prefer** local variables in functions
- **Use** trap handlers for cleanup
- **Support** both `--option=value` and `--option value` formats
- **Exit** with appropriate codes (0 for success, 1 for errors)

## Files to Never Commit

(See `.gitignore`)
- `.vscode/` - Editor configurations
- `.ignore` - Local ignore files
- Credentials or secrets files
- Temporary files

## Notes for AI Agents

- Scripts are standalone - no interdependencies
- Each script is self-contained with its own argument parsing
- No package manager or dependency management system
- Scripts target Linux systems (Ubuntu/Debian primarily)
- Focus on clarity and maintainability over cleverness
- When in doubt, follow the patterns in `pg_s3_backup`, `mount_nas`, or `setup_local_k8s`
