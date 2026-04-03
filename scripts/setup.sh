#!/bin/bash
# setup.sh - dev-retrospective 부트스트랩
# 새 머신에서 실행: bash ~/.dev-retrospective/scripts/setup.sh

set -euo pipefail

# Portable readlink (macOS readlink doesn't support -f)
resolve_link() {
  local target="$1"
  cd "$(dirname "$target")" 2>/dev/null
  target=$(basename "$target")
  while [ -L "$target" ]; do
    target=$(readlink "$target")
    cd "$(dirname "$target")" 2>/dev/null
    target=$(basename "$target")
  done
  echo "$(pwd -P)/$target"
}

REPO_ROOT="$HOME/.dev-retrospective"
CLAUDE_DIR="$HOME/.claude"
MACHINE=$(hostname -s)

# Dynamic vault detection
source "$REPO_ROOT/scripts/vault-detect.sh"
VAULT_BASE=$(find_vault)
VAULT_SESSIONS_SUBDIR="00. Inbox/03. AI Agent/sessions"
if [[ -n "$VAULT_BASE" ]]; then
  VAULT_SESSIONS="$VAULT_BASE/$VAULT_SESSIONS_SUBDIR"
else
  VAULT_SESSIONS=""
fi

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
echo "[1/8] Preparing commands directory..."
if [ -L "$CLAUDE_DIR/commands" ]; then
  echo "  Converting directory symlink to real directory..."
  LINK_TARGET=$(resolve_link "$CLAUDE_DIR/commands")
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
echo "[2/8] Linking retrospective commands..."
RETRO_CMDS="session-log dev-daily dev-weekly dev-monthly dev-checkin dev-consult dev-radar dev-inbox dev-setup dev-where"
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

# Verify symlinks
echo "  Verifying..."
LINK_OK=0
LINK_FAIL=0
for cmd in $RETRO_CMDS; do
  DST="$CLAUDE_DIR/commands/${cmd}.md"
  if [ -L "$DST" ] && [ -f "$DST" ]; then
    LINK_OK=$((LINK_OK + 1))
  else
    echo "  [WARN] Failed: ${cmd}.md"
    LINK_FAIL=$((LINK_FAIL + 1))
  fi
done
echo "  $LINK_OK OK, $LINK_FAIL failed"

# 3. Ensure ~/.claude/hooks/ is a real directory and link hooks
echo "[3/8] Linking hooks..."
if [ -L "$CLAUDE_DIR/hooks" ]; then
  LINK_TARGET=$(resolve_link "$CLAUDE_DIR/hooks")
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

for hook in session-backup.sh session-restore.sh cmds-pre-check.sh cmds-post-validate.sh; do
  SRC="$REPO_ROOT/hooks/$hook"
  DST="$CLAUDE_DIR/hooks/$hook"
  if [ -f "$SRC" ]; then
    ln -sf "$SRC" "$DST"
    chmod +x "$SRC"
    echo "  Linked: $hook"
  fi
done

# 4. Obsidian sessions symlink
echo "[4/8] Obsidian compatibility..."
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
      for f in "$BACKUP"/*.md; do
        [ -f "$f" ] || continue
        DEST="$REPO_ROOT/data/sessions/$(basename "$f")"
        [ -f "$DEST" ] || cp "$f" "$DEST"
      done
      if [ -d "$BACKUP/reviews" ]; then
        cp -R "$BACKUP/reviews/"* "$REPO_ROOT/data/" 2>/dev/null || true
      fi
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
echo "[5/8] Creating required directories..."
mkdir -p "$CLAUDE_DIR/logs"
mkdir -p "$CLAUDE_DIR/session-backups"
mkdir -p "$REPO_ROOT/data/sessions"
mkdir -p "$REPO_ROOT/data/reviews"/{daily,weekly,monthly,consult,radar,inbox}
mkdir -p "$REPO_ROOT/data/machines"
touch "$REPO_ROOT/data/machines/.gitkeep"

# 6. Skills symlink
echo "[6/8] Linking skills..."
SKILLS_DIR="$CLAUDE_DIR/skills/omc-learned"
mkdir -p "$SKILLS_DIR"
for skill_dir in "$REPO_ROOT/skills"/*/; do
  [ -d "$skill_dir" ] || continue
  SKILL_NAME=$(basename "$skill_dir")
  DST="$SKILLS_DIR/$SKILL_NAME"
  if [ -L "$DST" ]; then
    echo "  Already linked: $SKILL_NAME"
  elif [ -d "$DST" ]; then
    rm -rf "$DST"
    ln -sf "$skill_dir" "$DST"
    echo "  Replaced: $SKILL_NAME (dir -> symlink)"
  else
    ln -sf "$skill_dir" "$DST"
    echo "  Linked: $SKILL_NAME"
  fi
done

# 7. Cron setup
echo "[7/8] Cron setup..."
CRON_MARKER="# === dev-retrospective cron ==="
EXISTING_CRON=$(crontab -l 2>/dev/null || true)
OFFSET=0
VAULT_OFFSET=0

if echo "$EXISTING_CRON" | grep -q "$CRON_MARKER"; then
  echo "  Cron entries already exist, skipping"
else
  # Remove old vault-based cron entries
  CLEANED_CRON=$(echo "$EXISTING_CRON" | grep -v "Dev Review Automation" | grep -v "dev-review-cron" | grep -v "cron-daily\|cron-weekly\|cron-monthly" || true)

  # Calculate hostname-based stagger offsets
  OFFSET=$(( $(hostname -s | cksum | cut -d' ' -f1) % 5 ))
  VAULT_OFFSET=$(( (OFFSET + 5) % 60 ))

  NEW_CRON="$CLEANED_CRON
$CRON_MARKER
# Git 동기화 (30분마다)
*/30 * * * * cd $HOME/.dev-retrospective && git pull --rebase --quiet >> $HOME/.claude/logs/git-sync.log 2>&1
# 세션 데이터 자동 커밋 (매시간, stagger: ${OFFSET}분)
$OFFSET * * * * cd $HOME/.dev-retrospective && git pull --rebase --quiet && git add -A data/ && git diff --cached --quiet || (git commit -m \"auto: sync from \$(hostname -s)\" && git push || (sleep 10 && git pull --rebase && git push)) >> $HOME/.claude/logs/git-push.log 2>&1
# AI 보강 (매일 22:30 + hostname stagger)
30 22 * * * sleep \$(( \$(hostname -s | cksum | cut -d' ' -f1) % 300 )) && bash $HOME/.dev-retrospective/scripts/sync-and-enrich.sh >> $HOME/.claude/logs/enrich.log 2>&1
# Vault 커맨드 동기화 (매시간, push 후 5분)
$VAULT_OFFSET * * * * bash $HOME/.dev-retrospective/scripts/sync-to-vault.sh >> $HOME/.claude/logs/vault-sync.log 2>&1"

  echo "$NEW_CRON" | crontab -
  echo "  Cron entries installed"
fi

# 8. Vault command sync
echo "[8/8] Vault command sync..."
if [[ -n "$VAULT_BASE" ]]; then
  bash "$REPO_ROOT/scripts/sync-to-vault.sh"
else
  echo "  Vault not found, skipping vault sync"
fi

# Done
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Symlinks:"
echo "  ~/.claude/commands/dev-*.md -> ~/.dev-retrospective/commands/"
echo "  ~/.claude/commands/session-log.md -> ~/.dev-retrospective/commands/"
echo "  ~/.claude/hooks/session-*.sh -> ~/.dev-retrospective/hooks/"
echo "  ~/.claude/hooks/cmds-*.sh -> ~/.dev-retrospective/hooks/"
echo "  ~/.claude/skills/omc-learned/* -> ~/.dev-retrospective/skills/"
if [ -d "$VAULT_BASE" ]; then
  echo "  Obsidian sessions -> ~/.dev-retrospective/data/sessions/"
fi
echo ""
echo "Cron:"
echo "  */30 * * * * git pull --rebase (sync)"
echo "  $OFFSET * * * *    git add+commit+push (session data, staggered)"
echo "  30 22 * * *  AI enrichment (with stagger)"
echo "  $VAULT_OFFSET * * * *    Vault sync: repo/commands/ -> vault/commands/ (hourly)"
echo ""
echo "Commands: /session-log, /dev-daily, /dev-weekly, /dev-monthly"
echo "          /dev-checkin, /dev-consult, /dev-radar, /dev-inbox, /dev-setup"
echo "Skills: auto-checkin, auto-checkout, auto-retrospective"
