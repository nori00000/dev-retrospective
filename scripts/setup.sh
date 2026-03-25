#!/bin/bash
# setup.sh - dev-retrospective 부트스트랩
# 새 머신에서 실행: bash ~/.dev-retrospective/scripts/setup.sh

set -euo pipefail

REPO_ROOT="$HOME/.dev-retrospective"
CLAUDE_DIR="$HOME/.claude"
MACHINE=$(hostname -s)
VAULT_BASE="$HOME/Documents/Obsidian-0.1"
VAULT_SESSIONS="$VAULT_BASE/00. Inbox/03. AI Agent/sessions"

echo "=== dev-retrospective Setup ==="
echo "Machine: $MACHINE"
echo "Repo: $REPO_ROOT"
echo ""

# 0. Verify repo exists
if [ ! -d "$REPO_ROOT/commands" ]; then
  echo "[ERROR] Repo not found at $REPO_ROOT"
  echo "Run: git clone https://github.com/nori00000/dev-retrospective.git ~/.dev-retrospective"
  exit 1
fi

# 1. Ensure ~/.claude/commands/ is a real directory (not a symlink)
echo "[1/6] Preparing commands directory..."
if [ -L "$CLAUDE_DIR/commands" ]; then
  echo "  Converting directory symlink to real directory..."
  LINK_TARGET=$(readlink "$CLAUDE_DIR/commands")
  rm "$CLAUDE_DIR/commands"
  mkdir -p "$CLAUDE_DIR/commands"
  # Copy non-retrospective commands from old target
  if [ -d "$LINK_TARGET" ]; then
    for f in "$LINK_TARGET"/*.md; do
      [ -f "$f" ] || continue
      FNAME=$(basename "$f")
      case "$FNAME" in
        session-log.md|dev-daily.md|dev-weekly.md|dev-monthly.md|dev-checkin.md|dev-consult.md|dev-radar.md|dev-inbox.md|dev-setup.md)
          ;; # Skip retrospective commands - will symlink from repo
        *)
          cp "$f" "$CLAUDE_DIR/commands/$FNAME"
          echo "  Copied: $FNAME (general command)"
          ;;
      esac
    done
  fi
elif [ ! -d "$CLAUDE_DIR/commands" ]; then
  mkdir -p "$CLAUDE_DIR/commands"
fi

# 2. Create file-level symlinks for retrospective commands
echo "[2/6] Linking retrospective commands..."
RETRO_CMDS="session-log dev-daily dev-weekly dev-monthly dev-checkin dev-consult dev-radar dev-inbox dev-setup"
for cmd in $RETRO_CMDS; do
  SRC="$REPO_ROOT/commands/${cmd}.md"
  DST="$CLAUDE_DIR/commands/${cmd}.md"
  if [ -f "$SRC" ]; then
    ln -sf "$SRC" "$DST"
    echo "  Linked: ${cmd}.md"
  else
    echo "  [WARN] Source not found: $SRC"
  fi
done

# 3. Ensure ~/.claude/hooks/ is a real directory and link hooks
echo "[3/6] Linking hooks..."
if [ -L "$CLAUDE_DIR/hooks" ]; then
  LINK_TARGET=$(readlink "$CLAUDE_DIR/hooks")
  rm "$CLAUDE_DIR/hooks"
  mkdir -p "$CLAUDE_DIR/hooks"
  # Copy non-retrospective hooks
  if [ -d "$LINK_TARGET" ]; then
    for f in "$LINK_TARGET"/*; do
      [ -f "$f" ] || continue
      FNAME=$(basename "$f")
      case "$FNAME" in
        session-backup.sh|session-restore.sh)
          ;; # Will symlink from repo
        *)
          cp "$f" "$CLAUDE_DIR/hooks/$FNAME"
          ;;
      esac
    done
  fi
elif [ ! -d "$CLAUDE_DIR/hooks" ]; then
  mkdir -p "$CLAUDE_DIR/hooks"
fi

for hook in session-backup.sh session-restore.sh; do
  SRC="$REPO_ROOT/hooks/$hook"
  DST="$CLAUDE_DIR/hooks/$hook"
  if [ -f "$SRC" ]; then
    ln -sf "$SRC" "$DST"
    chmod +x "$SRC"
    echo "  Linked: $hook"
  fi
done

# 4. Obsidian sessions symlink
echo "[4/6] Obsidian compatibility..."
if [ -d "$VAULT_BASE" ]; then
  VAULT_SESSIONS_DIR="$VAULT_BASE/00. Inbox/03. AI Agent/sessions"
  if [ -d "$VAULT_SESSIONS_DIR" ] && [ ! -L "$VAULT_SESSIONS_DIR" ]; then
    # Real directory exists - move to backup, create symlink
    BACKUP="$VAULT_SESSIONS_DIR-backup-$(date +%Y%m%d)"
    mv "$VAULT_SESSIONS_DIR" "$BACKUP"
    ln -s "$REPO_ROOT/data/sessions" "$VAULT_SESSIONS_DIR"
    echo "  Sessions dir backed up to: $BACKUP"
    echo "  Symlinked: sessions -> repo/data/sessions"
    # Move backed up files into repo if any
    if [ "$(ls -A "$BACKUP" 2>/dev/null)" ]; then
      cp -n "$BACKUP"/*.md "$REPO_ROOT/data/sessions/" 2>/dev/null || true
      cp -rn "$BACKUP"/reviews/ "$REPO_ROOT/data/" 2>/dev/null || true
      echo "  Migrated existing session files to repo"
    fi
  elif [ -L "$VAULT_SESSIONS_DIR" ]; then
    echo "  Already a symlink, skipping"
  else
    # Directory doesn't exist
    mkdir -p "$(dirname "$VAULT_SESSIONS_DIR")"
    ln -s "$REPO_ROOT/data/sessions" "$VAULT_SESSIONS_DIR"
    echo "  Symlinked: sessions -> repo/data/sessions"
  fi
else
  echo "  Obsidian vault not found, skipping"
fi

# 5. Ensure required directories
echo "[5/6] Creating required directories..."
mkdir -p "$CLAUDE_DIR/logs"
mkdir -p "$CLAUDE_DIR/session-backups"
mkdir -p "$REPO_ROOT/data/sessions"
mkdir -p "$REPO_ROOT/data/reviews"/{daily,weekly,monthly,consult,radar,inbox}

# 6. Cron setup
echo "[6/6] Cron setup..."
CRON_MARKER="# === dev-retrospective cron ==="
EXISTING_CRON=$(crontab -l 2>/dev/null || true)

if echo "$EXISTING_CRON" | grep -q "dev-retrospective"; then
  echo "  Cron entries already exist, skipping"
else
  # Remove old vault-based cron entries
  CLEANED_CRON=$(echo "$EXISTING_CRON" | grep -v "Dev Review Automation" | grep -v "dev-review-cron" | grep -v "cron-daily\|cron-weekly\|cron-monthly" || true)

  NEW_CRON="$CLEANED_CRON
$CRON_MARKER
# Git 동기화 (30분마다)
*/30 * * * * cd $HOME/.dev-retrospective && git pull --ff-only >> $HOME/.claude/logs/git-sync.log 2>&1
# 세션 데이터 자동 커밋 (매시간)
0 * * * * cd $HOME/.dev-retrospective && git add -A data/ && git diff --cached --quiet || (git commit -m \"auto: sync from \$(hostname -s)\" && git push) >> $HOME/.claude/logs/git-push.log 2>&1
# AI 보강 (매일 22:30)
30 22 * * * bash $HOME/.dev-retrospective/scripts/sync-and-enrich.sh >> $HOME/.claude/logs/enrich.log 2>&1"

  echo "$NEW_CRON" | crontab -
  echo "  Cron entries installed"
fi

# Done
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Symlinks:"
echo "  ~/.claude/commands/dev-*.md -> ~/.dev-retrospective/commands/"
echo "  ~/.claude/commands/session-log.md -> ~/.dev-retrospective/commands/"
echo "  ~/.claude/hooks/session-*.sh -> ~/.dev-retrospective/hooks/"
if [ -d "$VAULT_BASE" ]; then
  echo "  Obsidian sessions -> ~/.dev-retrospective/data/sessions/"
fi
echo ""
echo "Cron:"
echo "  */30 * * * * git pull (sync)"
echo "  0 * * * *    git add+commit+push (session data)"
echo "  30 22 * * *  AI enrichment"
echo ""
echo "Commands: /session-log, /dev-daily, /dev-weekly, /dev-monthly"
echo "          /dev-checkin, /dev-consult, /dev-radar, /dev-inbox, /dev-setup"
