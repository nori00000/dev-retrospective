#Requires -Version 5.1
# sync-to-vault.ps1 - One-way sync: repo/commands/ -> vault/commands/
# Only syncs 9 retrospective commands. General commands untouched.
# Usage: powershell -ExecutionPolicy Bypass -File ~\.dev-retrospective\scripts\sync-to-vault.ps1

$ErrorActionPreference = "Continue"

$REPO_ROOT = Join-Path $env:USERPROFILE ".dev-retrospective"
$VAULT_CMDS_SUBDIR = "00. Inbox\03. AI Agent\scripts\claude-system\commands"

# --- Vault Detection (inline) ---
function Find-Vault {
    if ($env:DEV_RETRO_VAULT -and (Test-Path $env:DEV_RETRO_VAULT -PathType Container)) {
        return $env:DEV_RETRO_VAULT
    }

    $cacheFile = Join-Path $REPO_ROOT ".vault-path"
    if (Test-Path $cacheFile) {
        $cached = (Get-Content $cacheFile -Raw).Trim()
        $age = (Get-Date) - (Get-Item $cacheFile).LastWriteTime
        if ($age.TotalHours -lt 24 -and (Test-Path $cached -PathType Container)) {
            return $cached
        }
    }

    $searchRoots = @((Join-Path $env:USERPROFILE "Documents"))
    if ($env:OneDrive) { $searchRoots += Join-Path $env:OneDrive "Documents" }
    foreach ($drive in @("D:\", "E:\")) {
        if (Test-Path $drive) { $searchRoots += $drive }
    }

    foreach ($root in $searchRoots) {
        if (-not (Test-Path $root)) { continue }
        $obsidianDirs = Get-ChildItem -Path $root -Recurse -Directory -Filter ".obsidian" -Depth 3 -ErrorAction SilentlyContinue
        foreach ($dir in $obsidianDirs) {
            $vaultDir = $dir.Parent.FullName
            if (Test-Path (Join-Path $vaultDir $VAULT_CMDS_SUBDIR)) {
                New-Item -ItemType Directory -Path (Split-Path $cacheFile) -Force | Out-Null
                $vaultDir | Out-File -FilePath $cacheFile -NoNewline
                return $vaultDir
            }
        }
    }
    return $null
}

# --- Main ---
$vault = Find-Vault
if (-not $vault) {
    Write-Host "[vault-sync] Vault not found, skipping"
    exit 0
}

$vaultCmds = Join-Path $vault $VAULT_CMDS_SUBDIR
$repoCmds = Join-Path $REPO_ROOT "commands"

if (-not (Test-Path $vaultCmds)) {
    Write-Host "[vault-sync] Vault commands directory not found: $vaultCmds"
    exit 0
}

$retroCmds = @("session-log","dev-daily","dev-weekly","dev-monthly","dev-checkin","dev-consult","dev-radar","dev-inbox","dev-setup")

$synced = 0
$skipped = 0

foreach ($cmd in $retroCmds) {
    $src = Join-Path $repoCmds "$cmd.md"
    $dst = Join-Path $vaultCmds "$cmd.md"

    if (-not (Test-Path $src)) { continue }

    # Compare hashes - skip if identical
    if ((Test-Path $dst) -and ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash)) {
        $skipped++
        continue
    }

    Copy-Item $src $dst -Force
    $synced++
    Write-Host "  Updated: $cmd.md"
}

Write-Host "[vault-sync] Synced $synced/9 commands to vault ($skipped unchanged)"

# Also refresh ~/.claude/commands/ if in copy mode
$copyModeMarker = Join-Path $env:USERPROFILE ".claude\.retro-copy-mode"
if (Test-Path $copyModeMarker) {
    $claudeCmds = Join-Path $env:USERPROFILE ".claude\commands"
    $refreshed = 0
    foreach ($cmd in $retroCmds) {
        $src = Join-Path $repoCmds "$cmd.md"
        $dst = Join-Path $claudeCmds "$cmd.md"
        if ((Test-Path $src) -and (Test-Path $dst)) {
            if ((Get-FileHash $src).Hash -ne (Get-FileHash $dst).Hash) {
                Copy-Item $src $dst -Force
                $refreshed++
            }
        }
    }
    if ($refreshed -gt 0) {
        Write-Host "[vault-sync] Also refreshed $refreshed commands in ~/.claude/commands/ (copy mode)"
    }
}
