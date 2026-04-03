# Setup Guide

## 사전 요구사항

- macOS (Linux도 지원)
- git, gh (GitHub CLI)
- Claude Code CLI (AI 보강용)
- Obsidian (선택, 세션 파일 뷰어)

## 새 머신 설치

```bash
# 1. 리포 클론
git clone https://github.com/nori00000/dev-retrospective.git ~/.dev-retrospective

# 2. setup.sh 실행
bash ~/.dev-retrospective/scripts/setup.sh
```

setup.sh가 자동으로:
1. ~/.claude/commands/ 디렉토리 확인/생성
2. 회고 커맨드 10개 파일별 심링크 생성
3. hooks 파일별 심링크 생성
4. Obsidian sessions 심링크 (vault 있을 때만)
5. 크론잡 등록

## 수동 설정

### 심링크 수동 생성
```bash
# 커맨드
for cmd in session-log dev-daily dev-weekly dev-monthly dev-checkin dev-consult dev-radar dev-inbox dev-setup dev-where; do
  ln -sf ~/.dev-retrospective/commands/${cmd}.md ~/.claude/commands/${cmd}.md
done

# 훅
for hook in session-backup.sh session-restore.sh cmds-pre-check.sh cmds-post-validate.sh; do
  ln -sf ~/.dev-retrospective/hooks/${hook} ~/.claude/hooks/${hook}
done
```

### 크론 수동 등록
```bash
crontab -e
# 아래 내용 추가:
*/30 * * * * cd ~/.dev-retrospective && git pull --rebase --quiet >> ~/.claude/logs/git-sync.log 2>&1
0 * * * * cd ~/.dev-retrospective && git pull --rebase --quiet && git add -A data/ && git diff --cached --quiet || (git commit -m "auto: sync from $(hostname -s)" && git push) >> ~/.claude/logs/git-push.log 2>&1
30 22 * * * bash ~/.dev-retrospective/scripts/sync-and-enrich.sh >> ~/.claude/logs/enrich.log 2>&1
# Vault sync (hostname 기반 오프셋으로 머신간 충돌 방지)
{VAULT_OFFSET} * * * * bash ~/.dev-retrospective/scripts/sync-to-vault.sh >> ~/.claude/logs/vault-sync.log 2>&1
```

## 업데이트

```bash
cd ~/.dev-retrospective && git pull
```

커맨드/훅은 심링크이므로 pull만 하면 자동 반영됩니다.

## 문제 해결

### 커맨드가 안 보일 때
```bash
ls -la ~/.claude/commands/dev-daily.md
# 심링크가 깨졌으면:
bash ~/.dev-retrospective/scripts/setup.sh
```

### Obsidian에서 세션이 안 보일 때
```bash
ls -la ~/Documents/Obsidian-0.1/00.\ Inbox/03.\ AI\ Agent/sessions
# 심링크 확인, 없으면 setup.sh 재실행
```
