#!/usr/bin/env node
/**
 * Daily Budget Advisor for OMC HUD
 *
 * Reads OMC usage cache and outputs a custom rate-limit bucket
 * showing today's recommended daily budget and pace guidance.
 *
 * Output: JSON { version: 1, buckets: [...] } per OMC custom provider contract.
 */

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const home = homedir();
const configDir = process.env.CLAUDE_CONFIG_DIR || join(home, ".claude");

// OMC stores usage cache here
const cachePath = join(configDir, "plugins", "oh-my-claudecode", ".usage-cache.json");

function run() {
  const output = { version: 1, generatedAt: new Date().toISOString(), buckets: [] };

  if (!existsSync(cachePath)) {
    output.buckets.push({
      id: "daily-budget",
      label: "budget",
      usage: { type: "string", value: "no data" },
    });
    console.log(JSON.stringify(output));
    return;
  }

  let cache;
  try {
    const raw = JSON.parse(readFileSync(cachePath, "utf-8"));
    cache = raw.data || raw;
  } catch {
    output.buckets.push({
      id: "daily-budget",
      label: "budget",
      usage: { type: "string", value: "err" },
    });
    console.log(JSON.stringify(output));
    return;
  }

  const weeklyPct = cache.weeklyPercent ?? null;
  const weeklyResets = cache.weeklyResetsAt ? new Date(cache.weeklyResetsAt) : null;

  if (weeklyPct === null) {
    output.buckets.push({
      id: "daily-budget",
      label: "budget",
      usage: { type: "string", value: "n/a" },
    });
    console.log(JSON.stringify(output));
    return;
  }

  // Calculate days remaining until weekly reset
  const now = new Date();
  let daysLeft = 7;
  if (weeklyResets && weeklyResets > now) {
    daysLeft = Math.max(0.5, (weeklyResets.getTime() - now.getTime()) / (24 * 3600 * 1000));
  }

  const remaining = Math.max(0, 100 - weeklyPct);
  const dailyBudget = remaining / daysLeft;
  const roundedBudget = Math.round(dailyBudget);

  // Pace guidance in Korean shorthand
  let pace;
  if (dailyBudget >= 16) pace = "free";        // 넉넉
  else if (dailyBudget >= 12) pace = "good";    // 양호
  else if (dailyBudget >= 8) pace = "steady";   // 보통
  else if (dailyBudget >= 4) pace = "careful";  // 주의
  else pace = "save";                           // 절약

  output.buckets.push({
    id: "daily-budget",
    label: "budget",
    usage: { type: "string", value: `${roundedBudget}%/d ${pace}` },
  });

  console.log(JSON.stringify(output));
}

run();
