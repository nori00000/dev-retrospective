#Requires -Version 5.1
# setup.ps1 - dev-retrospective Windows setup
# Run: powershell -ExecutionPolicy Bypass -File ~\.dev-retrospective\scripts\setup.ps1

$ErrorActionPreference = "Stop"

$REPO_ROOT = Join-Path $env:USERPROFILE ".dev-retrospective"
$CLAUDE_DIR = Join-Path $env:USERPROFILE ".claude"
$MACHINE = [System.Net.Dns]::GetHostName()

# Vault subdirectory constants
$VAULT_CMDS_SUBDIR = "00. Inbox\03. AI Agent\scripts\claude-system\commands"
$VAULT_SESSIONS_SUBDIR = "00. Inbox\03. AI Agent\sessions"

# --- Vault Detection ---
function Find-Vault {
    # Priority 1: Environment variable
    if ($env:DEV_RETRO_VAULT -and (Test-Path $env:DEV_RETRO_VAULT -PathType Container)) {
        return $env:DEV_RETRO_VAULT
    }

    # Priority 2: Cached path (< 24h old)
    $cacheFile = Join-Path $REPO_ROOT ".vault-path"
    if (Test-Path $cacheFile) {
        $cached = Get-Content $cacheFile -Raw
        $cached = $cached.Trim()
        $age = (Get-Date) - (Get-Item $cacheFile).LastWriteTime
        if ($age.TotalHours -lt 24 -and (Test-Path $cached -PathType Container)) {
            return $cached
        }
    }

    # Priority 3: Search for .obsidian directories
    $searchRoots = @(
        (Join-Path $env:USERPROFILE "Documents")
    )
    if ($env:OneDrive) {
        $searchRoots += Join-Path $env:OneDrive "Documents"
    }
    foreach ($drive in @("D:\", "E:\")) {
        if (Test-Path $drive) { $searchRoots += $drive }
    }

    foreach ($root in $searchRoots) {
        if (-not (Test-Path $root)) { continue }
        $obsidianDirs = Get-ChildItem -Path $root -Recurse -Directory -Filter ".obsidian" -Depth 3 -ErrorAction SilentlyContinue
        foreach ($dir in $obsidianDirs) {
            $vaultDir = $dir.Parent.FullName
            if (Test-Path (Join-Path $vaultDir $VAULT_CMDS_SUBDIR)) {
                # Cache result
                New-Item -ItemType Directory -Path (Split-Path $cacheFile) -Force | Out-Null
                $vaultDir | Out-File -FilePath $cacheFile -NoNewline
                return $vaultDir
            }
        }
    }

    Write-Host "  [vault-detect] Vault not found. Set DEV_RETRO_VAULT env var to specify."
    return $null
}

# --- Symlink Helper ---
function New-LinkOrCopy {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Name,
        [switch]$IsDirectory
    )

    # Already correct symlink?
    $existing = Get-Item $Destination -ErrorAction SilentlyContinue
    if ($existing -and $existing.Target -eq $Source) {
        Write-Host "  Already linked: $Name"
        return "linked"
    }

    # Remove existing
    if (Test-Path $Destination) {
        Remove-Item $Destination -Force -Recurse -ErrorAction SilentlyContinue
    }

    # Try symbolic link (requires Developer Mode)
    try {
        if ($IsDirectory) {
            New-Item -ItemType Junction -Path $Destination -Target $Source -ErrorAction Stop | Out-Null
        } else {
            New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -ErrorAction Stop | Out-Null
        }
        Write-Host "  Linked: $Name"
        return "linked"
    } catch {
        # Fallback to copy
        if ($IsDirectory) {
            Copy-Item $Source $Destination -Recurse -Force
        } else {
            Copy-Item $Source $Destination -Force
        }
        Write-Host "  Copied: $Name (symlink failed, using copy mode)"
        return "copied"
    }
}

Write-Host "=== dev-retrospective Setup (Windows) ==="
Write-Host "Machine: $MACHINE"
Write-Host "Repo: $REPO_ROOT"
Write-Host ""

# 0. Verify repo
if (-not (Test-Path (Join-Path $REPO_ROOT "commands"))) {
    Write-Host "[ERROR] Repo not found at $REPO_ROOT"
    Write-Host "Run: git clone https://github.com/nori00000/dev-retrospective.git $REPO_ROOT"
    exit 1
}

# Detect vault
$VAULT_BASE = Find-Vault
if ($VAULT_BASE) {
    $VAULT_SESSIONS = Join-Path $VAULT_BASE $VAULT_SESSIONS_SUBDIR
    Write-Host "Vault: $VAULT_BASE"
} else {
    $VAULT_SESSIONS = $null
    Write-Host "Vault: not found (vault steps will be skipped)"
}
Write-Host ""

$copyMode = $false

# [1/8] Commands directory
Write-Host "[1/8] Preparing commands directory..."
$cmdsDir = Join-Path $CLAUDE_DIR "commands"
New-Item -ItemType Directory -Path $cmdsDir -Force | Out-Null

# [2/8] Link retrospective commands
Write-Host "[2/8] Linking retrospective commands..."
$retroCmds = @("session-log","dev-daily","dev-weekly","dev-monthly","dev-checkin","dev-consult","dev-radar","dev-inbox","dev-setup")
$linkOk = 0; $linkFail = 0

foreach ($cmd in $retroCmds) {
    $src = Join-Path $REPO_ROOT "commands\$cmd.md"
    $dst = Join-Path $cmdsDir "$cmd.md"
    if (Test-Path $src) {
        $result = New-LinkOrCopy -Source $src -Destination $dst -Name "$cmd.md"
        if ($result -eq "copied") { $copyMode = $true }
        $linkOk++
    } else {
        Write-Host "  [WARN] Source not found: $src"
        $linkFail++
    }
}
Write-Host "  $linkOk OK, $linkFail failed"

if ($copyMode) {
    # Create marker for copy mode detection
    "" | Out-File -FilePath (Join-Path $CLAUDE_DIR ".retro-copy-mode") -NoNewline
    Write-Host "  NOTE: Running in copy mode. Commands will be refreshed by vault sync."
}

# [3/8] Hooks
Write-Host "[3/8] Linking hooks..."
$hooksDir = Join-Path $CLAUDE_DIR "hooks"
New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null

# Check for Git Bash
$gitBash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $gitBash) {
    Write-Host "  WARNING: Git Bash not found. Hooks (.sh files) require Git for Windows."
    Write-Host "  Install from: https://gitforwindows.org/"
    Write-Host "  If WSL is installed, set CLAUDE_CODE_GIT_BASH_PATH in settings.json"
}

foreach ($hook in @("session-backup.sh","session-restore.sh","cmds-pre-check.sh","cmds-post-validate.sh")) {
    $src = Join-Path $REPO_ROOT "hooks\$hook"
    $dst = Join-Path $hooksDir $hook
    if (Test-Path $src) {
        New-LinkOrCopy -Source $src -Destination $dst -Name $hook | Out-Null
    }
}

# [4/8] Obsidian compatibility
Write-Host "[4/8] Obsidian compatibility..."
if ($VAULT_BASE -and $VAULT_SESSIONS) {
    $sessionsDataDir = Join-Path $REPO_ROOT "data\sessions"
    New-Item -ItemType Directory -Path $sessionsDataDir -Force | Out-Null

    if (Test-Path $VAULT_SESSIONS) {
        $item = Get-Item $VAULT_SESSIONS -ErrorAction SilentlyContinue
        if ($item -and $item.Attributes -match "ReparsePoint") {
            Write-Host "  Already a junction/symlink, skipping"
        } else {
            # Backup existing directory
            $backup = "$VAULT_SESSIONS-backup-$(Get-Date -Format 'yyyyMMdd')"
            if (Test-Path $VAULT_SESSIONS) {
                Move-Item $VAULT_SESSIONS $backup
                Write-Host "  Backed up to: $backup"
            }
            # Create junction (no admin required)
            New-Item -ItemType Junction -Path $VAULT_SESSIONS -Target $sessionsDataDir | Out-Null
            Write-Host "  Junction created: sessions -> repo/data/sessions"
        }
    } else {
        New-Item -ItemType Directory -Path (Split-Path $VAULT_SESSIONS) -Force | Out-Null
        New-Item -ItemType Junction -Path $VAULT_SESSIONS -Target $sessionsDataDir | Out-Null
        Write-Host "  Junction created: sessions -> repo/data/sessions"
    }
} else {
    Write-Host "  Vault not found, skipping"
}

# [5/8] Required directories
Write-Host "[5/8] Creating required directories..."
@(
    (Join-Path $CLAUDE_DIR "logs"),
    (Join-Path $CLAUDE_DIR "session-backups"),
    (Join-Path $REPO_ROOT "data\sessions"),
    (Join-Path $REPO_ROOT "data\reviews\daily"),
    (Join-Path $REPO_ROOT "data\reviews\weekly"),
    (Join-Path $REPO_ROOT "data\reviews\monthly"),
    (Join-Path $REPO_ROOT "data\reviews\consult"),
    (Join-Path $REPO_ROOT "data\reviews\radar"),
    (Join-Path $REPO_ROOT "data\reviews\inbox")
) | ForEach-Object {
    New-Item -ItemType Directory -Path $_ -Force | Out-Null
}

# [6/8] Skills
Write-Host "[6/8] Linking skills..."
$skillsDir = Join-Path $CLAUDE_DIR "skills\omc-learned"
New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
$repoSkills = Join-Path $REPO_ROOT "skills"
if (Test-Path $repoSkills) {
    Get-ChildItem -Path $repoSkills -Directory | ForEach-Object {
        $dst = Join-Path $skillsDir $_.Name
        New-LinkOrCopy -Source $_.FullName -Destination $dst -Name $_.Name -IsDirectory | Out-Null
    }
}

# [7/8] Task Scheduler
Write-Host "[7/8] Task Scheduler setup..."
$offset = [Math]::Abs($MACHINE.GetHashCode() % 5)
$vaultOffset = ($offset + 5) % 60

$tasks = @(
    @{
        Name = "dev-retro-git-pull"
        Description = "dev-retrospective: Git pull (every 30 min)"
        Execute = "git"
        Arguments = "pull --rebase --quiet"
        WorkingDir = $REPO_ROOT
        IntervalMinutes = 30
        StartMinute = $offset
    },
    @{
        Name = "dev-retro-git-push"
        Description = "dev-retrospective: Auto commit and push (hourly)"
        Execute = "powershell"
        Arguments = "-ExecutionPolicy Bypass -File `"$(Join-Path $REPO_ROOT 'scripts\auto-push.ps1')`""
        WorkingDir = $REPO_ROOT
        IntervalMinutes = 60
        StartMinute = $offset
    },
    @{
        Name = "dev-retro-vault-sync"
        Description = "dev-retrospective: Vault command sync (hourly)"
        Execute = "powershell"
        Arguments = "-ExecutionPolicy Bypass -File `"$(Join-Path $REPO_ROOT 'scripts\sync-to-vault.ps1')`""
        WorkingDir = $REPO_ROOT
        IntervalMinutes = 60
        StartMinute = $vaultOffset
    }
)

foreach ($task in $tasks) {
    # Remove existing
    $existing = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
    if ($existing) {
        Unregister-ScheduledTask -TaskName $task.Name -Confirm:$false
    }

    $trigger = New-ScheduledTaskTrigger -Once -At "00:$("{0:D2}" -f $task.StartMinute)" `
        -RepetitionInterval (New-TimeSpan -Minutes $task.IntervalMinutes)
    $action = New-ScheduledTaskAction -Execute $task.Execute -Argument $task.Arguments `
        -WorkingDirectory $task.WorkingDir
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    Register-ScheduledTask -TaskName $task.Name -Description $task.Description `
        -Trigger $trigger -Action $action -Settings $settings -ErrorAction SilentlyContinue | Out-Null

    if ($?) {
        Write-Host "  Registered: $($task.Name)"
    } else {
        Write-Host "  [WARN] Failed to register: $($task.Name) (may need admin)"
    }
}

# Daily enrich task
$enrichName = "dev-retro-enrich"
$existing = Get-ScheduledTask -TaskName $enrichName -ErrorAction SilentlyContinue
if ($existing) {
    Unregister-ScheduledTask -TaskName $enrichName -Confirm:$false
}
$enrichMinute = 30 + ($offset % 3)
$enrichTrigger = New-ScheduledTaskTrigger -Daily -At "22:$("{0:D2}" -f $enrichMinute)"
$enrichAction = New-ScheduledTaskAction -Execute "bash" `
    -Argument "$(Join-Path $REPO_ROOT 'scripts/sync-and-enrich.sh')"
$enrichSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $enrichName -Description "dev-retrospective: AI enrichment (daily)" `
    -Trigger $enrichTrigger -Action $enrichAction -Settings $enrichSettings -ErrorAction SilentlyContinue | Out-Null
if ($?) {
    Write-Host "  Registered: $enrichName (requires Git Bash)"
} else {
    Write-Host "  [WARN] Failed to register: $enrichName"
}

# [8/8] Vault sync
Write-Host "[8/8] Vault command sync..."
$syncScript = Join-Path $REPO_ROOT "scripts\sync-to-vault.ps1"
if ($VAULT_BASE -and (Test-Path $syncScript)) {
    & powershell -ExecutionPolicy Bypass -File $syncScript
} elseif (-not $VAULT_BASE) {
    Write-Host "  Vault not found, skipping"
} else {
    Write-Host "  sync-to-vault.ps1 not found, skipping"
}

# Done
Write-Host ""
Write-Host "=== Setup Complete ==="
Write-Host ""
Write-Host "Symlinks:"
Write-Host "  ~\.claude\commands\dev-*.md -> ~\.dev-retrospective\commands\"
Write-Host "  ~\.claude\hooks\*.sh -> ~\.dev-retrospective\hooks\"
Write-Host "  ~\.claude\skills\omc-learned\* -> ~\.dev-retrospective\skills\"
if ($VAULT_BASE) {
    Write-Host "  Obsidian sessions -> ~\.dev-retrospective\data\sessions\"
}
if ($copyMode) {
    Write-Host "  NOTE: Running in copy mode (Developer Mode off). Use sync-to-vault.ps1 to refresh."
}
Write-Host ""
Write-Host "Task Scheduler:"
Write-Host "  dev-retro-git-pull     (every 30 min, offset: $offset min)"
Write-Host "  dev-retro-git-push     (hourly, offset: $offset min)"
Write-Host "  dev-retro-vault-sync   (hourly, offset: $vaultOffset min)"
Write-Host "  dev-retro-enrich       (daily 22:$("{0:D2}" -f $enrichMinute))"
Write-Host ""
Write-Host "Commands: /session-log, /dev-daily, /dev-weekly, /dev-monthly"
Write-Host "          /dev-checkin, /dev-consult, /dev-radar, /dev-inbox, /dev-setup"
