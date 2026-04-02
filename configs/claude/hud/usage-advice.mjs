#!/usr/bin/env node
/**
 * Usage Advisor — prints a startup tip based on current Claude Max usage.
 * Called from the cc() shell function before launching Claude Code.
 */

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const home = homedir();
const configDir = process.env.CLAUDE_CONFIG_DIR || join(home, ".claude");
const cachePath = join(configDir, "plugins", "oh-my-claudecode", ".usage-cache.json");

// ANSI colors
const R = "\x1b[0m";
const DIM = "\x1b[2m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const CYAN = "\x1b[36m";
const BOLD = "\x1b[1m";

function run() {
  if (!existsSync(cachePath)) return;

  let data;
  try {
    const raw = JSON.parse(readFileSync(cachePath, "utf-8"));
    data = raw.data || raw;
  } catch { return; }

  const wk = data.weeklyPercent;
  const fh = data.fiveHourPercent;
  const sonnet = data.sonnetWeeklyPercent;
  if (wk == null) return;

  // Calculate daily budget
  const resetAt = data.weeklyResetsAt ? new Date(data.weeklyResetsAt) : null;
  const now = new Date();
  let daysLeft = 7;
  if (resetAt && resetAt > now) {
    daysLeft = Math.max(0.5, (resetAt - now) / (24 * 3600 * 1000));
  }
  const remaining = Math.max(0, 100 - wk);
  const daily = remaining / daysLeft;

  // Status bar
  const wkColor = wk >= 90 ? RED : wk >= 70 ? YELLOW : GREEN;
  const fhColor = fh >= 90 ? RED : fh >= 70 ? YELLOW : GREEN;

  const bar = (pct, width = 20) => {
    const filled = Math.round((pct / 100) * width);
    return `${wkColor}${"█".repeat(filled)}${DIM}${"░".repeat(width - filled)}${R}`;
  };

  console.log("");
  console.log(`${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}`);
  console.log(`  ${BOLD}📊 Usage Dashboard${R}`);
  console.log(`${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}`);
  console.log(`  ${DIM}주간 Opus :${R} [${bar(wk)}] ${wkColor}${Math.round(wk)}%${R}  ${DIM}(${Math.round(daysLeft)}일 후 리셋)${R}`);
  console.log(`  ${DIM}5시간 창  :${R} ${fhColor}${Math.round(fh)}%${R}  ${DIM}|${R}  ${DIM}주간 Sonnet:${R} ${GREEN}${sonnet != null ? Math.round(sonnet) + "%" : "n/a"}${R}`);
  console.log("");

  // Advice
  const dailyRound = Math.round(daily);

  console.log(`  ${DIM}기본: Sonnet${R} ${DIM}|${R} ${CYAN}Ctrl+Shift+M${R}${DIM}→모델 전환${R}`);
  console.log("");

  if (wk >= 90) {
    console.log(`  ${RED}⚠ 주간 Opus 거의 소진! (하루 ${dailyRound}% 이내)${R}`);
    console.log(`  ${DIM}→${R} Sonnet으로 코딩, Opus는 정말 필요할 때만`);
  } else if (wk >= 70) {
    console.log(`  ${YELLOW}⚡ Opus 예산: ~${dailyRound}%/일 — 절제 모드${R}`);
    console.log(`  ${DIM}→${R} 코딩은 Sonnet, Opus는 기획·리뷰·디버깅에만`);
  } else if (wk >= 40) {
    console.log(`  ${GREEN}✦ Opus 예산: ~${dailyRound}%/일 — 보통 페이스${R}`);
    console.log(`  ${DIM}→${R} 코딩은 Sonnet, 복잡한 판단은 Opus`);
  } else {
    console.log(`  ${GREEN}✦ Opus 예산: ~${dailyRound}%/일 — 넉넉!${R}`);
    console.log(`  ${DIM}→${R} Opus 자유롭게, 단순 작업만 Sonnet`);
  }

  if (fh >= 80) {
    console.log(`  ${DIM}→${R} ${YELLOW}5시간 창 ${Math.round(fh)}%${R} — 잠시 쉬면 곧 리셋됩니다`);
  }

  console.log(`${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}`);
  console.log("");
}

run();
