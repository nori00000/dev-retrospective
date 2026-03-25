# Session Log - Obsidian CMDS Session Logger + GitHub Devlog

$ARGUMENTS

## Instructions

이 세션의 작업 내용을 분석하여 **두 가지 출력**을 생성합니다:
1. **Obsidian CMDS 규격 세션 로그** (상세)
2. **GitHub devlog** (간결, 프로젝트 리포 내)

### 1. 세션 컨텍스트 수집

현재 세션의 대화 내용을 분석하여 다음을 정리하세요:

- **작업 요약**: 이 세션에서 수행한 주요 작업들 (3-5줄)
- **변경된 파일**: 생성/수정/삭제한 파일 목록 (경로 + 변경 유형)
- **핵심 결정**: 내린 기술적/설계 결정과 그 이유
- **배운 점 (TIL)**: 세션 중 발견한 인사이트, 트러블슈팅 경험
- **미완료 작업**: 남은 TODO나 후속 작업
- **review_tags**: 이 세션의 주제 분류 태그 (예: architecture, crawler, refactoring, testing, debugging)
- **session_metrics**: 변경 파일 수, 추가/삭제 줄 수, 테스트 수, 커밋 수

### 2. 머신 & 프로젝트 정보 수집

다음 명령어를 실행하여 환경 정보를 수집하세요:

```bash
MACHINE=$(hostname -s)
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
PROJECT=$(basename "$(pwd)")
CURRENT_DIR=$(pwd)
```

### 3. 세션 메트릭 수집

```bash
# 이 세션의 git 통계 (최근 커밋 기준)
FILES_CHANGED=$(git diff --stat HEAD~1 2>/dev/null | tail -1 | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo "0")
LINES_ADDED=$(git diff --stat HEAD~1 2>/dev/null | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
LINES_DELETED=$(git diff --stat HEAD~1 2>/dev/null | tail -1 | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
COMMITS_TODAY=$(git log --oneline --since="$(date +%Y-%m-%d)" 2>/dev/null | wc -l | tr -d ' ')
```

### 4. 파일명 생성

- `$ARGUMENTS`가 주어졌으면 제목으로 사용, 없으면 세션 작업에서 적절한 제목 추론
- slug 변환: 소문자, 공백→하이픈, 한글 허용, 특수문자 제거
- 파일명 형식: `YYYY-MM-DD-HHmm-{slug}.md`
- 예: `2026-02-16-1430-api-개발.md`

### 5. 디렉토리 확인

```bash
# Obsidian 세션 디렉토리
mkdir -p "$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions"

# GitHub devlog 디렉토리 (git 프로젝트인 경우만)
if [ -n "$GIT_ROOT" ]; then
  mkdir -p "$GIT_ROOT/devlog/sessions"
fi
```

### 6. Obsidian CMDS 규격 노트 생성

**저장 경로**: `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/{파일명}`

**YAML 규칙 (필수)**:
- YAML frontmatter는 반드시 **2-space** 들여쓰기
- Markdown body는 **TAB** 들여쓰기
- wikilink는 반드시 `"[[...]]"` 따옴표로 감싸기
- 날짜는 ISO 8601 (`YYYY-MM-DD`)

**노트 형식**:

```
---
type: session-log
aliases:
  - "{제목}"
author:
  - "[[이상민]]"
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
tags:
  - session-log
  - {관련-태그들}
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Session Logs]]"
status: completed
machine: {hostname -s 결과}
agent: claude-code
project: {project-name}
git_branch: {branch}
review_tags:
  - {tag1}
  - {tag2}
session_metrics:
  files_changed: {N}
  lines_added: {N}
  lines_deleted: {N}
  tests_passed: {N or "N/A"}
  commits: {N}
---

# {제목}

> **세션 정보**
> - 날짜: {YYYY-MM-DD HH:mm}
> - 머신: {machine}
> - 에이전트: Claude Code
> - 프로젝트: {project} (`{pwd}`)
> - 브랜치: {git_branch}

---

## 작업 요약

{세션에서 수행한 주요 작업 3-5줄 요약}

## 상세 작업 내역

### 1. {작업1 제목}

{작업 설명 - 무엇을 왜 어떻게 했는지}

### 2. {작업2 제목}

{작업 설명}

## 변경된 파일

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `path/to/file` | 생성/수정/삭제 | 변경 내용 |

## 핵심 결정

- **{결정1}**: {이유와 맥락}
- **{결정2}**: {이유와 맥락}

## 배운 점 (TIL)

- {인사이트 1}
- {인사이트 2}

## 미완료 / 후속 작업

- [ ] {TODO 1}
- [ ] {TODO 2}

---

> [!info] 관련 노트
> - {관련 노트 wikilinks}
```

### 7. GitHub Devlog 생성 (git 프로젝트인 경우만)

`$GIT_ROOT`이 비어있지 않은 경우에만 실행합니다.

**저장 경로**: `{GIT_ROOT}/devlog/sessions/{파일명}`

**형식** (간결한 markdown, CMDS frontmatter 없음):

```markdown
# {제목}

- **날짜**: {YYYY-MM-DD}
- **프로젝트**: {project}
- **브랜치**: {git_branch}

## 작업 요약

{3-5줄 요약}

## 변경된 파일

| 파일 | 변경 | 설명 |
|------|------|------|
| `path/to/file` | 수정 | 설명 |

## 핵심 결정

- {결정1}: {이유}

## 배운 점 (TIL)

- {교훈1}

## 후속 작업

- [ ] {TODO1}
```

### 8. 완료 확인

생성 후 다음을 확인하세요:

1. Obsidian 파일이 `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/`에 존재
2. (git 프로젝트인 경우) devlog 파일이 `{GIT_ROOT}/devlog/sessions/`에 존재
3. YAML frontmatter의 들여쓰기가 2-space인지 확인
4. 모든 wikilink가 따옴표로 감싸져 있는지 확인
5. review_tags와 session_metrics가 포함되어 있는지 확인
6. 생성된 파일의 전체 경로를 사용자에게 출력

## Output

```
## 세션 로그 생성 완료

- **Obsidian**: {전체 경로}
- **Devlog**: {전체 경로 또는 "N/A (git 프로젝트 아님)"}
- **제목**: {제목}
- **머신**: {machine}
- **프로젝트**: {project}
- **메트릭**: {files_changed} files, +{lines_added}/-{lines_deleted}, {commits} commits

Obsidian과 GitHub devlog에서 확인할 수 있습니다.
```
