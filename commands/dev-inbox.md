# Dev Inbox - 기술 발견 기록

$ARGUMENTS

## Instructions

새로운 기술, 도구, 방법론, 아이디어를 빠르게 기록합니다.
축적된 항목들은 `/dev-consult`와 `/dev-radar`에서 함께 검토합니다.

### 1. 입력 처리

`$ARGUMENTS` 분석:
- **항목 이름**: 기술/도구/방법론
- **출처**: URL, 사람, 이벤트
- **카테고리**: tool | library | framework | method | pattern | article | idea
- **관련 프로젝트**: 어느 프로젝트에 적용 가능
- **메모**: 사용자 코멘트

`$ARGUMENTS`가 "list" 또는 비어있으면 현재 inbox 현황 출력.

### 2. 간단 리서치 (선택)

구체적 기술/도구인 경우 빠르게 조사:
- GitHub 스타 수, 최근 활동
- 공식 문서 URL
- 주요 특징 1-3개

### 3. Inbox 파일에 추가

**저장 경로**: `~/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/inbox/dev-inbox.md`

```bash
mkdir -p "$HOME/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/sessions/reviews/inbox"
```

**append-only** 방식. 파일 없으면 생성, 있으면 맨 아래 추가.

```
---
type: dev-inbox
aliases:
  - "기술 발견 인박스"
author:
  - "[[이상민]]"
date created: {YYYY-MM-DD}
date modified: {YYYY-MM-DD}
tags:
  - dev-inbox
  - living-document
CMDS: "[[📚 907 Technology & Development Division]]"
index: "[[🏷 Dev Reviews]]"
status: active
---

# 기술 발견 인박스

## 미검토 항목

### [{YYYY-MM-DD}] {항목 이름}
- **카테고리**: {category}
- **출처**: {source}
- **관련 프로젝트**: {project}
- **메모**: {comment}
- **상태**: 🆕 미검토

---
```

### 4. 검토 시 상태 변경

`/dev-consult`나 `/dev-radar`에서 검토 시:
- 🆕 미검토 → ✅ 도입 | 🧪 실험 | 📖 학습 | ⏸️ 보류 | ❌ 스킵

## Output (항목 추가 시)

```
## Dev Inbox에 추가됨
- **항목**: {이름}
- **미검토 항목**: {N}개

다음 /dev-consult에서 검토됩니다.
```

## Output (list 모드)

```
## Dev Inbox 현황

### 미검토 ({N}개)
1. [{날짜}] {항목} - {카테고리}

### 최근 검토 ({N}개)
1. [{날짜}] {항목} - {상태}
```
