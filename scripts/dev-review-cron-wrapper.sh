#!/bin/bash
# Cron wrapper - 경로에 공백이 있어서 cron에서 직접 호출이 안 되므로 wrapper 사용
exec "/Users/leesangmin/Documents/Obsidian-0.1/00. Inbox/03. AI Agent/scripts/dev-review-cron.sh" "$@"
