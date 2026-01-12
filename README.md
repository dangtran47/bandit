# Bandit CTF Password Manager

A simple Makefile-based tool for managing Bandit CTF passwords and SSH connections.

## Getting Started

To start from scratch, check out the starter branch:

```bash
git checkout starter
```

## Usage

### SSH Connection
```bash
# Connect to specific level
make ssh level=1
make 1                    # Shorthand for above
make s level=1           # Shorthand using 's'

# Examples
make 0                   # Connect to bandit0
make 5                   # Connect to bandit5
make s level=10          # Connect to bandit10
```

### Adding New Passwords
```bash
# Add password with auto-increment level
make add <password>
make a <password>        # Shorthand using 'a'

# Add password to specific level
make add <password> <level>
make a <password> <level>    # Shorthand using 'a'

# Examples
make add mynewpassword       # Creates next level (e.g., 4.md)
make a secretpass 10         # Creates 10.md with password
```

## How It Works

- Password files are stored as `<level>.md` (e.g., `0.md`, `1.md`, `2.md`)
- Each file contains the password for that level on the first line
- Level 0 uses default password "bandit0"
- SSH connects to `bandit<level>@bandit.labs.overthewire.org` on port 2220
- Auto-increment finds the highest existing level and adds 1

## Commands

| Command | Description |
|---------|-------------|
| `make <level>` | Connect to bandit level (shorthand) |
| `make ssh level=<level>` | Connect to bandit level |
| `make s level=<level>` | Connect to bandit level (shorthand) |
| `make add <password> [level]` | Add new password file |
| `make a <password> [level]` | Add new password file (shorthand) |
| `make n` | Connect to newest/next level (auto-increment) |
| `make cm` | Commit all .md password files to git |