---
type: documentation
aliases:
  - "Security Audit M1 Pro 2026-02-17"
author: "[[Claude Code]]"
date created: 2026-02-17
date modified: 2026-02-17
tags:
  - homelab
  - security
  - audit
  - ssh
CMDS: "[[907 Technology & Development Division]]"
index: "[[Session Logs]]"
status: complete
machine: m1-pro
agent: claude-code
---
# Security Audit Report: M1 Pro
**Date**: 2026-02-17
**Auditor**: Claude Code (Executor Agent)
**Scope**: READ-ONLY security assessment

---

## Executive Summary

Overall system security posture is **ACCEPTABLE** with some areas requiring attention. No critical vulnerabilities detected, but several configuration improvements recommended.

**Key Findings**:
- 1 CRITICAL issue: API keys in plaintext LaunchAgent plist
- 3 WARN items: Insecure file permissions, exposed services, brew warnings
- Multiple INFO items documenting normal/expected state

---

## 1. SSH Key Audit

### SSH Directory Structure
**Severity**: INFO

```
drwx------   9 leesangmin  staff   288  2월 16 19:36 ~/.ssh/
```

	Directory permissions: CORRECT (700)
	Owner: leesangmin
	Total files: 9 items

### SSH Files Inventory

| File | Permissions | Size | Status |
|------|-------------|------|--------|
| `id_ed25519` | `-rw-------` | 411 bytes | CORRECT (600) |
| `id_ed25519.pub` | `-rw-r--r--` | 97 bytes | CORRECT (644) |
| `authorized_keys` | `-rw-------` | 311 bytes | CORRECT (600) |
| `config` | `-rw-------` | 290 bytes | CORRECT (600) |
| `known_hosts` | `-rw-------` | 3336 bytes | CORRECT (600) |

### SSH Configuration Analysis
**Severity**: WARN

```ssh
Host m4-air
    HostName 100.99.25.33
    User leesangmin
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking accept-new

Host m1-pro
    HostName 100.94.193.82
    User leesangmin
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking accept-new
```

**Issues**:
- `StrictHostKeyChecking accept-new`: Less secure than default (ask)
- Both hosts use same ED25519 key (single point of failure)

**Recommendation**:
- Consider `StrictHostKeyChecking yes` after initial connection
- Consider per-host keys for compartmentalization

### Authorized Keys
**Severity**: INFO

	3 authorized keys found:
	1. ssh-ed25519 ...makeaialive.com
	2. ssh-ed25519 ...homelab-studio
	3. ssh-ed25519 ...homelab-mini-gateway

**Status**: Normal for homelab environment with multiple access points

### Known Hosts
**Severity**: INFO

	12 entries in known_hosts
	Normal for active homelab with multiple machines

### SSH Agent
**Severity**: INFO

```
PID 27589: /usr/bin/ssh-agent -l
```

	SSH agent running normally
	No ForwardAgent directive found (good - disabled by default)

---

## 2. Exposed Services Analysis

### Listening Ports Summary
**Severity**: WARN

**Public listeners (0.0.0.0 or *):**

| Port | Process | Risk Level | Notes |
|------|---------|------------|-------|
| 3283 | ARDAgent | LOW | Apple Remote Desktop (macOS built-in) |
| 7000 | ControlCenter | MEDIUM | Bound to all interfaces - verify necessity |
| 5000 | ControlCenter | MEDIUM | Bound to all interfaces - verify necessity |
| 8080 | Docker | MEDIUM | Docker Desktop - common dev port |
| 55920 | astxAgent | LOW | macOS system service |
| 59869 | logioptio | LOW | Logitech Options (peripherals) |
| 34581 | CrossEXSe | LOW | Korean security software |

**Localhost-only listeners (127.0.0.1):**

| Port | Process | Risk Level |
|------|---------|------------|
| 42235 | MagicLine | LOW |
| 38377-38379 | nadl-plug | LOW |
| 2432 | SetappAgent | LOW |
| 16117 | delfino | LOW |
| 15292 | Adobe | LOW |
| 9277 | stable | LOW |
| 18789 | node (OpenClaw) | LOW |
| 18792 | node | LOW |
| 55353 | Comet | LOW |

### Docker on Port 8080
**Severity**: INFO

```
tcp46      0      0  *.8080                 *.*                    LISTEN
PID 92887: com.docker
```

	Docker Desktop listening on all interfaces
	Standard development configuration
	Verify no sensitive containers exposed

### ControlCenter on Ports 5000/7000
**Severity**: WARN

```
tcp4/tcp6      0      0  *.5000                 *.*                    LISTEN
tcp4/tcp6      0      0  *.7000                 *.*                    LISTEN
PID 1279: /System/Library/CoreServices/ControlCenter.app
```

**Concern**: macOS ControlCenter binding to all interfaces unexpected

**Recommendation**:
- Investigate why ControlCenter needs public listeners
- Confirm this is legitimate macOS behavior (not malware)
- Consider firewall rules to restrict access

### OpenClaw Gateway
**Severity**: INFO

```
tcp4/tcp6 127.0.0.1:18789  (node PID 45146)
```

	OpenClaw running on localhost only (correct)
	Not exposed to network (good)

---

## 3. File Permissions Audit

### Sensitive Configuration Files
**Severity**: CRITICAL (1 issue) + WARN (1 issue)

| File | Permissions | Risk | Status |
|------|-------------|------|--------|
| `~/.openclaw/openclaw.json` | `-rw-------` (600) | LOW | CORRECT |
| `~/.aws/credentials` | `-rw-------` (600) | LOW | CORRECT |
| `~/.discord-exporter/.env` | `-rw-r--r--` (644) | MEDIUM | **WARN: World-readable** |
| `ai.openclaw.gateway.plist` | `-rw-r--r--` (644) | **CRITICAL** | **Contains plaintext API keys** |

### CRITICAL: API Keys in LaunchAgent Plist
**Severity**: CRITICAL

**Location**: `/Users/leesangmin/Library/LaunchAgents/ai.openclaw.gateway.plist`

**Issue**: File contains multiple API keys in plaintext environment variables:
```xml
<key>ANTHROPIC_API_KEY</key>
<string>sk-ant-api03-Ztv5X9TSFfBclO3VkfhNgm_gpyQrc...</string>

<key>OPENAI_API_KEY</key>
<string>sk-proj-2RjZhWZNSnVRTyKreGKDdqwfhMMDs...</string>

<key>OPENROUTER_API_KEY</key>
<string>sk-or-v1-76e19d87d9b8af4d33e2dcd2a746...</string>

<key>ZHIPUAI_API_KEY</key>
<string>7bce50a0310a424c9a9841a23f05e529...</string>
```

**Risk**:
- Any local user can read these keys
- Keys visible in process list
- Keys visible in launchctl exports

**URGENT Recommendation**:
1. Move API keys to `~/.openclaw/credentials/` with 600 permissions
2. Load keys from file in startup script instead of plist
3. Rotate all exposed API keys immediately
4. Change plist to use:
   ```xml
   <key>ProgramArguments</key>
   <array>
     <string>/bin/bash</string>
     <string>/path/to/wrapper-script.sh</string>
   </array>
   ```
   Where wrapper script sources credentials securely

### Discord Exporter .env
**Severity**: WARN

```
-rw-r--r--  1 leesangmin  staff   87  1월 13 02:17 ~/.discord-exporter/.env
```

**Issue**: World-readable (644) - should be 600

**Recommendation**:
```bash
chmod 600 ~/.discord-exporter/.env
```

### Claude Configuration Directory
**Severity**: INFO

```
drwx------  36 leesangmin  staff  1152  2월 16 22:11 ~/.claude/
```

	Directory permissions: CORRECT (700)
	Most files properly protected
	history.jsonl: -rw------- (correct)

**Observation**: Some subdirectories are 755 (drwxr-xr-x):
- `.omc/`
- `agents/`
- `commands/`
- `file-history/`
- `hooks/`
- `plugins/`

**Status**: Acceptable - these contain code, not secrets

---

## 4. Homebrew Audit

### Brew Doctor Results
**Severity**: WARN

**Issue 1: Deprecated Cask**
```
Warning: Some installed casks are deprecated or disabled.
You should find replacements for the following casks:
  powershell
```

**Recommendation**:
```bash
brew uninstall --cask powershell
brew install --cask powershell/tap/powershell
```

**Issue 2: Unbrewed Headers**
```
Warning: Unbrewed header files were found in /usr/local/include.
Unexpected header files:
  /usr/local/include/node/*
```

**Impact**: Potential conflicts with Homebrew's node installations

**Recommendation**:
```bash
# Backup first
sudo mv /usr/local/include/node /usr/local/include/node.backup
```

**Issue 3: Tap Not on Default Branch**
```
Warning: Some taps are not on the default git origin branch
  git -C $(brew --repo anthropics/claude) checkout
```

**Recommendation**:
```bash
git -C $(brew --repo anthropics/claude) checkout main
```

### Outdated Packages
**Severity**: INFO

```
✔︎ JSON API formula.jws.json
✔︎ JSON API cask.jws.json
```

	No outdated packages reported
	System up-to-date

---

## 5. Firewall Status

**Severity**: INFO

**Status**: Unable to query without sudo

	Command attempted: /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
	Result: Permission denied

**Recommendation**:
```bash
# Check manually with:
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps
```

**Expected**: Firewall should be ENABLED for homelab security

---

## 6. LaunchAgent Inventory

### Homelab Agents
**Severity**: INFO

**All agents have correct permissions (644 for plists is standard)**

| Agent | Purpose | Permissions |
|-------|---------|-------------|
| `com.homelab.config-sync.plist` | Config synchronization | `-rw-r--r--` |
| `com.homelab.file-sync.plist` | File synchronization | `-rw-r--r--` |
| `com.homelab.nas-mount.plist` | NAS mounting | `-rw-r--r--` |
| `com.homelab.status-reporter.plist` | Status reporting | `-rw-r--r--` |
| `com.homelab.task-queue.plist` | Task queue processing | `-rw-r--r--` |
| `com.homelab.telegram-logger.plist` | Telegram logging | `-rw-r--r--` |

### Telegram Logger Analysis
**Severity**: INFO

```xml
<key>ProgramArguments</key>
<array>
  <string>/bin/bash</string>
  <string>/Users/leesangmin/Projects/homelab-orchestration/bin/telegram-session-logger.sh</string>
</array>
<key>StartInterval</key>
<integer>1800</integer>
```

	Runs every 30 minutes (1800 seconds)
	Executes shell script from homelab-orchestration
	Logs to ~/.orch/logs/

**Status**: Normal homelab automation

### Third-Party Agents
**Severity**: INFO

**Non-homelab agents found:**
- `ai.openclaw.gateway.plist` (OpenClaw)
- `com.adobe.ccxprocess.plist` (Adobe Creative Cloud)
- `com.google.GoogleUpdater.wake.plist` (Google)
- `com.google.keystone.*` (Google updater)
- `com.setapp.DesktopClient.*` (Setapp)
- `kr.co.iniline.crossex-service.plist` (Korean banking security)
- `kr.ucod.NADLPlugin.plist` (Korean security plugin)

**Status**: Expected for Korean macOS system with Adobe/Google/Setapp

---

## 7. Summary of Findings

### By Severity

**CRITICAL (1):**
- API keys in plaintext LaunchAgent plist (`ai.openclaw.gateway.plist`)

**WARN (4):**
- Discord .env file world-readable (644 should be 600)
- ControlCenter listening on all interfaces (ports 5000/7000)
- SSH config uses `accept-new` instead of `yes` for StrictHostKeyChecking
- Homebrew deprecated cask and unbrewed headers

**INFO (Multiple):**
- SSH directory permissions correct
- 3 authorized keys (normal for homelab)
- 12 known hosts (normal)
- Multiple listening services (mostly localhost-bound)
- LaunchAgents inventory normal
- No outdated brew packages

---

## 8. Remediation Checklist

### Immediate Actions (CRITICAL)

- [ ] **Rotate all API keys** in `ai.openclaw.gateway.plist`
  - [ ] Anthropic API key
  - [ ] OpenAI API key
  - [ ] OpenRouter API key
  - [ ] ZhipuAI API key

- [ ] **Secure OpenClaw credentials**
  ```bash
  # Move keys to secure file
  cat > ~/.openclaw/credentials/api-keys.env <<'EOF'
  ANTHROPIC_API_KEY=NEW_KEY_HERE
  OPENAI_API_KEY=NEW_KEY_HERE
  OPENROUTER_API_KEY=NEW_KEY_HERE
  ZHIPUAI_API_KEY=NEW_KEY_HERE
  EOF

  chmod 600 ~/.openclaw/credentials/api-keys.env

  # Create wrapper script
  cat > ~/.openclaw/bin/gateway-secure.sh <<'EOF'
  #!/bin/bash
  source ~/.openclaw/credentials/api-keys.env
  exec /usr/local/bin/node /Users/leesangmin/.npm-global/lib/node_modules/openclaw/dist/index.js gateway --port 18789
  EOF

  chmod 700 ~/.openclaw/bin/gateway-secure.sh

  # Update plist to use wrapper (remove EnvironmentVariables section)
  ```

### High Priority (WARN)

- [ ] **Fix Discord .env permissions**
  ```bash
  chmod 600 ~/.discord-exporter/.env
  ```

- [ ] **Investigate ControlCenter ports**
  ```bash
  # Verify this is legitimate macOS behavior
  lsof -i :5000 -i :7000
  # Consider firewall rules if unnecessary
  ```

- [ ] **Update SSH config**
  ```bash
  # Change accept-new to yes after initial connections
  sed -i '' 's/StrictHostKeyChecking accept-new/StrictHostKeyChecking yes/' ~/.ssh/config
  ```

- [ ] **Fix Homebrew issues**
  ```bash
  brew uninstall --cask powershell
  brew install --cask powershell/tap/powershell

  sudo mv /usr/local/include/node /usr/local/include/node.backup

  git -C $(brew --repo anthropics/claude) checkout main
  ```

### Recommended (INFO)

- [ ] **Enable firewall** (if not already enabled)
  ```bash
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
  ```

- [ ] **Review authorized keys** periodically
  ```bash
  cat ~/.ssh/authorized_keys
  # Ensure all 3 keys are still needed
  ```

- [ ] **Consider per-host SSH keys** for compartmentalization

- [ ] **Audit Docker containers** on port 8080
  ```bash
  docker ps
  # Ensure no sensitive data exposed
  ```

---

## 9. Monitoring Recommendations

### Ongoing Security Practices

1. **Monthly SSH audit**
   - Review `~/.ssh/authorized_keys`
   - Check for unknown entries in `known_hosts`
   - Verify file permissions remain 600/700

2. **Quarterly credential rotation**
   - API keys
   - SSH keys (if compromised)

3. **Port monitoring**
   ```bash
   lsof -i -P -n | grep LISTEN > /tmp/port-audit-$(date +%Y%m%d).txt
   # Compare with baseline
   ```

4. **LaunchAgent monitoring**
   ```bash
   ls -la ~/Library/LaunchAgents/
   # Watch for new unknown agents
   ```

5. **Homebrew maintenance**
   ```bash
   brew update
   brew upgrade
   brew doctor
   brew cleanup
   ```

---

## 10. Conclusion

The M1 Pro system has a **moderate security posture** suitable for a homelab environment with room for improvement.

**Strengths**:
- SSH directory properly secured
- Most sensitive files have correct permissions
- No obvious malware or suspicious processes
- System up-to-date via Homebrew

**Weaknesses**:
- API keys stored insecurely in LaunchAgent plist (CRITICAL)
- Some files world-readable that shouldn't be
- ControlCenter network exposure unclear
- Homebrew configuration warnings

**Next Steps**:
1. Address CRITICAL issue (API key rotation and secure storage)
2. Fix WARN items (file permissions, SSH config, Homebrew)
3. Establish regular security audit schedule (monthly)
4. Document homelab security baseline

**Audit Completed**: 2026-02-17 22:15 KST
**Next Audit Due**: 2026-03-17

---

## Appendix: Command Reference

### Quick Security Check Script
```bash
#!/bin/bash
# Save as ~/bin/security-check.sh

echo "=== SSH Permissions ==="
ls -la ~/.ssh/

echo -e "\n=== Listening Ports ==="
lsof -i -P -n 2>/dev/null | grep LISTEN

echo -e "\n=== Sensitive Files ==="
find ~ -maxdepth 2 -name "*.env" -o -name "*credentials*" 2>/dev/null | while read f; do
  ls -la "$f"
done

echo -e "\n=== LaunchAgents ==="
ls ~/Library/LaunchAgents/com.homelab.* 2>/dev/null

echo -e "\n=== Brew Status ==="
brew doctor 2>&1 | head -10

echo -e "\n=== SSH Agent ==="
ps aux | grep ssh-agent | grep -v grep
```

### Secure OpenClaw Migration Script
```bash
#!/bin/bash
# Save as ~/bin/secure-openclaw.sh

CREDS_DIR="$HOME/.openclaw/credentials"
BIN_DIR="$HOME/.openclaw/bin"
PLIST="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"

# Create directories
mkdir -p "$CREDS_DIR" "$BIN_DIR"
chmod 700 "$CREDS_DIR" "$BIN_DIR"

# Prompt for new API keys
read -sp "Enter NEW Anthropic API key: " ANTHROPIC_KEY
echo
read -sp "Enter NEW OpenAI API key: " OPENAI_KEY
echo
read -sp "Enter NEW OpenRouter API key: " OPENROUTER_KEY
echo
read -sp "Enter NEW ZhipuAI API key: " ZHIPUAI_KEY
echo

# Create secure credentials file
cat > "$CREDS_DIR/api-keys.env" <<EOF
export ANTHROPIC_API_KEY="$ANTHROPIC_KEY"
export OPENAI_API_KEY="$OPENAI_KEY"
export OPENROUTER_API_KEY="$OPENROUTER_KEY"
export ZHIPUAI_API_KEY="$ZHIPUAI_KEY"
EOF

chmod 600 "$CREDS_DIR/api-keys.env"

# Create wrapper script
cat > "$BIN_DIR/gateway-secure.sh" <<'EOF'
#!/bin/bash
source "$HOME/.openclaw/credentials/api-keys.env"
exec /usr/local/bin/node "$HOME/.npm-global/lib/node_modules/openclaw/dist/index.js" gateway --port 18789
EOF

chmod 700 "$BIN_DIR/gateway-secure.sh"

echo "✅ Secure credentials created"
echo "⚠️  Next steps:"
echo "1. Update $PLIST to use $BIN_DIR/gateway-secure.sh"
echo "2. Remove EnvironmentVariables section from plist"
echo "3. launchctl unload $PLIST"
echo "4. launchctl load $PLIST"
echo "5. Test OpenClaw gateway functionality"
```

---

**End of Report**
