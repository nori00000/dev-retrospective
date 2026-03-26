# Multi-Platform Setup Guide

dev-retrospective 시스템의 멀티플랫폼 설정 가이드.

## Supported Platforms

| Feature | macOS | Linux | Windows |
|---------|-------|-------|---------|
| Commands symlink | symlink | symlink | Symlink/Junction/Copy |
| Hooks execution | bash | bash | Git Bash required |
| Vault auto-detect | find + .obsidian | find + .obsidian | Get-ChildItem + .obsidian |
| Cron/Scheduler | crontab | crontab | Task Scheduler |
| Vault sync | sync-to-vault.sh | sync-to-vault.sh | sync-to-vault.ps1 |
| Sessions link | symlink | symlink | Junction |

## Quick Start

### macOS / Linux

```bash
# 1. Clone repo
git clone https://github.com/nori00000/dev-retrospective.git ~/.dev-retrospective

# 2. Run setup
bash ~/.dev-retrospective/scripts/setup.sh
```

### Windows

```powershell
# 1. Clone repo
git clone https://github.com/nori00000/dev-retrospective.git $env:USERPROFILE\.dev-retrospective

# 2. Run setup
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\.dev-retrospective\scripts\setup.ps1
```

## Vault Auto-Detection

### How It Works

`vault-detect.sh` (bash) and `Find-Vault` (PowerShell) search for the Obsidian vault automatically:

1. **Environment variable** (highest priority): `DEV_RETRO_VAULT=/path/to/vault`
2. **Cached path**: `~/.dev-retrospective/.vault-path` (24h TTL)
3. **Auto-search**: Finds `.obsidian/` directories in known locations:
   - macOS: `~/Documents/`, `~/Library/Mobile Documents/`
   - Linux: `~/Documents/`, `~/Dropbox/`, `~/`
   - Windows: `%USERPROFILE%\Documents\`, `%OneDrive%\Documents\`, `D:\`, `E:\`
4. **Validation**: Confirms vault contains `00. Inbox/03. AI Agent/scripts/claude-system/commands/`
5. **Preference**: If multiple vaults found, prefers one with "Obsidian" in name

### Override

Set the environment variable to skip auto-detection:

```bash
# macOS/Linux (add to ~/.zshrc or ~/.bashrc)
export DEV_RETRO_VAULT="$HOME/Documents/Obsidian-0.1"

# Windows (PowerShell profile or System Settings > Environment Variables)
$env:DEV_RETRO_VAULT = "$env:USERPROFILE\Documents\Obsidian-0.1"
```

### Clear Cache

Delete the cache file to force re-detection:

```bash
rm ~/.dev-retrospective/.vault-path
```

## Windows-Specific Notes

### Git Bash Requirement

Claude Code hooks (`.sh` files) require Git Bash on Windows. Install [Git for Windows](https://gitforwindows.org/).

### WSL Conflict

If WSL (Windows Subsystem for Linux) is installed, `bash` may resolve to WSL's bash instead of Git Bash, causing hooks to fail.

**Fix**: Add to Claude Code `settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

See: [GitHub Issue #23556](https://github.com/anthropics/claude-code/issues/23556)

### Symlink Modes

Windows setup uses a 3-tier fallback:

1. **Symbolic link** (preferred): Requires Developer Mode enabled
   - Settings > Update & Security > For Developers > Developer Mode: ON
2. **Junction** (directories only): Works without admin or Developer Mode
3. **File copy** (last resort): Creates `.retro-copy-mode` marker in `~/.claude/`
   - In copy mode, `sync-to-vault.ps1` also refreshes `~/.claude/commands/`

### sync-and-enrich.sh on Windows

The AI enrichment script is bash-only. On Windows it runs via Git Bash in Task Scheduler. If Git Bash is not installed, this task silently fails. A native PowerShell version is a future enhancement.

## Multi-Machine Setup

### Hostname-Based Cron Stagger

When multiple machines run the same cron jobs, they can conflict on `git push`. The system uses hostname-based time staggering:

```
OFFSET = hostname_hash % 5  (0-4 minutes)
```

This means:
- Machine A pushes at :02, Machine B pushes at :04
- Machine A enriches at 22:30 + random(0-300s)
- Near-zero probability of simultaneous push

### Conflict Resolution

If push still conflicts:
1. `git pull --rebase` before every push
2. On push failure: sleep 10s, pull --rebase, retry
3. Maximum 1 retry (logged for debugging)

### Sync Flow

```
Mac A: edit commands/ -> git commit -> git push
                                          |
GitHub: ─────────────────────────────────┐
                                          |
Mac B: cron git pull ─────────────> sync-to-vault.sh ─────> vault
                                                              |
                                                   remotely-save (auto)
                                                              |
Windows: vault updated ─────────────────────────> commands available
```

## Troubleshooting

### Vault not detected

```bash
# Check manually
source ~/.dev-retrospective/scripts/vault-detect.sh
find_vault
# If empty, set explicitly:
export DEV_RETRO_VAULT="/path/to/your/obsidian/vault"
bash ~/.dev-retrospective/scripts/setup.sh
```

### Hooks not firing on Windows

1. Verify Git Bash is installed: `where.exe bash`
2. Check it's NOT WSL: the path should contain `Git`, not `System32`
3. If WSL conflict: set `CLAUDE_CODE_GIT_BASH_PATH` in settings

### Task Scheduler tasks not running

```powershell
# Check registered tasks
Get-ScheduledTask | Where-Object {$_.TaskName -like "dev-retro-*"} | Format-Table TaskName, State

# Run a task manually
Start-ScheduledTask -TaskName "dev-retro-git-pull"
```

### Git push conflicts between machines

```bash
# Check logs
cat ~/.claude/logs/git-push.log | tail -20

# Manual resolution
cd ~/.dev-retrospective
git pull --rebase
git push
```

### Copy mode detection (Windows)

```powershell
# Check if running in copy mode
Test-Path "$env:USERPROFILE\.claude\.retro-copy-mode"
# If true: commands are copied, not symlinked
# Enable Developer Mode to switch to symlinks
```

### Commands not updated after repo change

```bash
# macOS/Linux: Commands are symlinks, auto-updated
ls -la ~/.claude/commands/dev-daily.md

# If broken, re-run setup:
bash ~/.dev-retrospective/scripts/setup.sh

# Windows (copy mode): manually sync
powershell -ExecutionPolicy Bypass -File ~\.dev-retrospective\scripts\sync-to-vault.ps1
```

## Linux Verification

```bash
# 1. Run setup
bash ~/.dev-retrospective/scripts/setup.sh

# 2. Verify commands linked
ls -la ~/.claude/commands/dev-daily.md  # Should show symlink

# 3. Verify vault detection (empty if no vault installed)
source ~/.dev-retrospective/scripts/vault-detect.sh
echo "Vault: $(find_vault)"

# 4. Verify cron
crontab -l | grep dev-retrospective

# 5. Verify no hardcoded paths
grep -r "/Users/" ~/.dev-retrospective/hooks/ && echo "FAIL" || echo "PASS"
```
