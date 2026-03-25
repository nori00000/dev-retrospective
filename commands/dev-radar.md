# Dev Radar - 기술 트렌드 탐색

$ARGUMENTS

## Instructions

현재 프로젝트와 기술 스택에 관련된 **최신 기술 트렌드**를 탐색합니다.

### 1. 현재 기술 스택 파악

```bash
PROJECT=$(basename "$(pwd)")
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
```

프로젝트의 기술 스택 파악: package.json, requirements.txt, pyproject.toml, Cargo.toml, go.mod, Dockerfile 등

### 2. 트렌드 탐색

`$ARGUMENTS` 주어지면 해당 주제 집중, 없으면 현재 스택 기반 탐색.

WebSearch로 다음 소스들 검색:
- GitHub trending repos
- Hacker News, Dev.to
- 기술 블로그 (한국어 포함)
- 공식 블로그, 릴리스 노트

### 3. Technology Radar 분류

| 링 | 의미 | 기준 |
|----|------|------|
| **Adopt** | 지금 적용 | 성숙, 문제 해결, 낮은 리스크 |
| **Trial** | 작게 시도 | 유망하지만 검증 필요 |
| **Assess** | 조사/학습 | 흥미롭지만 판단 보류 |
| **Hold** | 보류 | 맞지 않거나 시기상조 |

### 4. 사용자 상의

AskUserQuestion으로 분류 합의

### 5. 저장

**Obsidian**: `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/radar/{YYYY-MM-DD}-tech-radar.md`

```bash
mkdir -p "$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/radar"
```

```
---
type: tech-radar
aliases:
  - "{YYYY-MM-DD} 기술 레이더"
author:
  - "[[이상민]]"
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
tags:
  - tech-radar
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: completed
project: {project}
---

# {YYYY-MM-DD} 기술 레이더

## Adopt / Trial / Assess / Hold

## 현재 스택 업데이트 체크

| 패키지 | 현재 | 최신 | 변경사항 |
|--------|------|------|---------|
```

Adopt/Trial 항목은 dev-inbox에도 자동 기록.

## Output

```
## 기술 레이더 완료
- **Adopt**: {N}개 / **Trial**: {N}개 / **Assess**: {N}개 / **Hold**: {N}개
```
