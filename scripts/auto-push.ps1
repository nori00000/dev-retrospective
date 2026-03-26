#Requires -Version 5.1
# auto-push.ps1 - Windows auto commit and push for dev-retrospective
# Called by Task Scheduler (dev-retro-git-push)

$ErrorActionPreference = "Continue"

$repoRoot = Join-Path $env:USERPROFILE ".dev-retrospective"
$logDir = Join-Path $env:USERPROFILE ".claude\logs"
$logFile = Join-Path $logDir "git-push.log"

# Ensure log directory
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

Set-Location $repoRoot

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Pull before push (conflict prevention)
"[$timestamp] Starting auto-push..." | Out-File -Append $logFile
git pull --rebase --quiet 2>&1 | Out-File -Append $logFile

# Stage data changes
git add -A data/

# Check if anything staged
git diff --cached --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    $hostname = [System.Net.Dns]::GetHostName()
    git commit -m "auto: sync from $hostname" 2>&1 | Out-File -Append $logFile

    git push 2>&1 | Out-File -Append $logFile
    if ($LASTEXITCODE -ne 0) {
        # Retry with rebase
        "[$timestamp] Push failed, retrying after rebase..." | Out-File -Append $logFile
        Start-Sleep -Seconds 10
        git pull --rebase --quiet 2>&1 | Out-File -Append $logFile
        git push 2>&1 | Out-File -Append $logFile

        if ($LASTEXITCODE -ne 0) {
            "[$timestamp] Push retry also failed!" | Out-File -Append $logFile
        } else {
            "[$timestamp] Push succeeded after retry" | Out-File -Append $logFile
        }
    } else {
        "[$timestamp] Push succeeded" | Out-File -Append $logFile
    }
} else {
    "[$timestamp] No changes to push" | Out-File -Append $logFile
}
