# Dev Setup - 개발 시스템 설정

$ARGUMENTS

## Instructions

현재 머신에 개발 회고 시스템을 설정합니다.
Obsidian vault (Google Drive 동기화)를 중앙 소스로 사용합니다.

### 1. 현재 상태 확인

```bash
MACHINE=$(hostname -s)
VAULT_BASE="$HOME/Documents/Obsidian-0.1"
SYSTEM_DIR="$VAULT_BASE/00. Inbox/03. AI Agent/scripts/claude-system"
CLAUDE_DIR="$HOME/.claude"

echo "Machine: $MACHINE"
echo "Vault: $VAULT_BASE"
echo "System: $SYSTEM_DIR"

# 현재 symlink 상태 확인
if [ -L "$CLAUDE_DIR/commands" ]; then
  echo "Commands: LINKED -> $(readlink $CLAUDE_DIR/commands)"
else
  echo "Commands: LOCAL (not linked)"
fi

if [ -L "$CLAUDE_DIR/hooks" ]; then
  echo "Hooks: LINKED -> $(readlink $CLAUDE_DIR/hooks)"
else
  echo "Hooks: LOCAL (not linked)"
fi
```

### 2. $ARGUMENTS 처리

- `$ARGUMENTS`가 비어있거나 "status"이면: 현재 상태만 출력
- `$ARGUMENTS`가 "install"이면: setup.sh 실행
- `$ARGUMENTS`가 "sync"이면: vault -> local 강제 동기화 (symlink 재생성)
- `$ARGUMENTS`가 "cron"이면: cron 설정 안내

### 3. 설치 (install 모드)

```bash
bash "$SYSTEM_DIR/setup.sh"
```

### 4. 동기화 확인 (sync 모드)

```bash
# vault의 commands 목록
echo "=== Vault Commands ==="
ls "$SYSTEM_DIR/commands/"

# 실제 ~/.claude/commands/ 에서 보이는 파일
echo "=== Active Commands ==="
ls "$CLAUDE_DIR/commands/"

# 차이 확인
diff <(ls "$SYSTEM_DIR/commands/") <(ls "$CLAUDE_DIR/commands/") || echo "차이 있음!"
```

### 5. 머신별 상태 리포트

```bash
# 세션 로그에서 머신별 세션 수 집계
SESSIONS_DIR="$VAULT_BASE/00. Inbox/03. AI Agent/sessions"
echo "=== Machine Session Counts ==="
grep -h "^machine:" "$SESSIONS_DIR"/*.md 2>/dev/null | sort | uniq -c | sort -rn
```

## Output

```
## Dev Setup: {machine}

### 시스템 상태
- **머신**: {hostname}
- **Commands**: {LINKED/LOCAL} ({N}개)
- **Hooks**: {LINKED/LOCAL} ({N}개)
- **Vault 동기화**: {OK/NOT SYNCED}
- **Cron**: {설정됨/미설정}

### 사용 가능한 커맨드
{커맨드 목록}

### 머신별 세션 통계
| 머신 | 세션 수 |
|------|--------|
| {machine1} | {N} |
| {machine2} | {N} |
```
