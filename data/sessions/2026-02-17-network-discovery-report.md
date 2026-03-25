---
type: documentation
aliases:
  - "Network Discovery Report 2026-02-17"
author: "[[Claude Code]]"
date created: 2026-02-17
date modified: 2026-02-17
tags:
  - homelab
  - network
  - tailscale
  - ssh
  - discovery
CMDS: "[[907 Technology & Development Division]]"
index: "[[Session Logs]]"
status: complete
machine: m1-pro
agent: claude-code
---
# Network Discovery Report 2026-02-17

Generated: 2026-02-16T22:14:31+0900

## Executive Summary

Probed 8 machines in the homelab environment using Tailscale, mDNS, and SSH. Key findings:

- **4 machines REACHABLE** via Tailscale (m4-air, m1-pro, m4-studio, mini-gateway)
- **2 machines OFFLINE** (desktop-fng6a7o, samsung-sm-f946n)
- **4 machines NOT DISCOVERABLE** via mDNS (mini-build, mini-util, mini-media, dgx-spark)
- **SSH ACCESS BLOCKED** on 2 reachable machines (m4-studio, mini-gateway) due to host key verification

## Machine Status Table

| Machine | Tailscale IP | mDNS Status | SSH Status | OS | Uptime |
|---------|-------------|-------------|------------|-----|--------|
| **m4-air** | 100.99.25.33 | ✓ (172.30.1.6) | ✓ WORKING | macOS 26.3 (25D125) | 1 day, 1:49 |
| **m1-pro** | 100.94.193.82 | ✓ (localhost) | ✓ WORKING | macOS 26.3 (25D125) | 1 day, 1:40 |
| **m4-studio** | 100.87.39.34 | ✓ (172.30.1.44) | ✗ Host key verification failed | Unknown | Unknown |
| **mini-gateway** | 100.89.236.78 | ✓ (172.30.1.42) | ✗ Host key verification failed | Unknown | Unknown |
| **mini-build** | Unknown | ✗ DNS resolution failed | ✗ DNS resolution failed | Unknown | Unknown |
| **mini-util** | Unknown | ✗ DNS resolution failed | ✗ DNS resolution failed | Unknown | Unknown |
| **mini-media** | Unknown | ✗ DNS resolution failed | ✗ DNS resolution failed | Unknown | Unknown |
| **dgx-spark** | Unknown | ✗ DNS resolution failed | ✗ DNS resolution failed | Unknown | Unknown |

## Detailed Findings

### Reachable Machines

#### m4-air (100.99.25.33)
- **Status**: FULLY OPERATIONAL
- **Tailscale**: Active with direct connection (172.30.1.6:41641)
- **mDNS**: Resolved to 172.30.1.6
- **SSH**: ✓ Working (user: leesangmin)
- **Hardware**: ARM64 (Darwin Kernel 25.3.0)
- **OS**: macOS 26.3 (Build 25D125)
- **Uptime**: 1 day, 1:49, load avg: 2.40 2.32 2.22
- **Disk**: 926GB total, 11GB used, 600GB available (2% capacity)
- **Ping latency**: 6-17ms (Tailscale), 4-5ms (mDNS/local)

#### m1-pro (100.94.193.82) - LOCALHOST
- **Status**: FULLY OPERATIONAL (current machine)
- **Tailscale**: Active
- **mDNS**: Local loopback
- **SSH**: ✓ Working (user: leesangmin)
- **Hardware**: ARM64 T6000 (Darwin Kernel 25.3.0)
- **OS**: macOS 26.3 (Build 25D125)
- **Uptime**: 1 day, 1:40, load avg: 5.55 5.62 5.82
- **Disk**: 926GB total, 11GB used, 574GB available (2% capacity)
- **Ping latency**: <1ms (localhost)

#### m4-studio (100.87.39.34)
- **Status**: REACHABLE but SSH BLOCKED
- **Tailscale**: Active (marked as "alive-macstudio")
- **mDNS**: Resolved to 172.30.1.44
- **SSH**: ✗ Host key verification failed
- **Ping latency**: 25-65ms (Tailscale), 4-6ms (mDNS/local)
- **Action Required**: SSH host key needs to be accepted in known_hosts

#### mini-gateway (100.89.236.78)
- **Status**: REACHABLE but SSH BLOCKED
- **Tailscale**: Idle (tx 12616 rx 11480)
- **mDNS**: Resolved to 172.30.1.42
- **SSH**: ✗ Host key verification failed
- **SSH User**: alive
- **Ping latency**: 5-13ms (Tailscale), 4-102ms (mDNS - high variance)
- **Action Required**: SSH host key needs to be accepted in known_hosts

### Unreachable Machines

#### mini-build, mini-util, mini-media, dgx-spark
- **Status**: NOT DISCOVERABLE
- **Tailscale**: No presence in tailscale status output
- **mDNS**: DNS resolution failed (nodename nor servname provided, or not known)
- **SSH**: Cannot connect (DNS failure)
- **Possible Causes**:
  - Machines powered off
  - Not connected to network
  - Not running Tailscale daemon
  - mDNS responder not configured/running
  - Hostname mismatch

### Offline Machines (from Tailscale status)

#### desktop-fng6a7o (100.80.57.93)
- **Status**: OFFLINE
- **Last seen**: 6 days ago
- **Platform**: Windows
- **Note**: Not in original probe list but appears in Tailscale network

#### samsung-sm-f946n (100.108.13.1)
- **Status**: OFFLINE
- **Last seen**: 35 days ago
- **Platform**: Android
- **Note**: Mobile device, expected to be intermittent

## Tailscale Peer List

```
IP              Hostname            User           Platform  Status
100.94.193.82   m1-pro              makeaialive@   macOS     active (current)
100.87.39.34    alive-macstudio     makeaialive@   macOS     active
100.80.57.93    desktop-fng6a7o     makeaialive@   windows   offline (6d)
100.99.25.33    m4-air              makeaialive@   macOS     active (direct)
100.89.236.78   mini-gateway        makeaialive@   macOS     idle
100.108.13.1    samsung-sm-f946n    makeaialive@   android   offline (35d)
```

Active peers: 4 (m1-pro, alive-macstudio, m4-air, mini-gateway)
Offline peers: 2 (desktop-fng6a7o, samsung-sm-f946n)

## NAS Mount Status

Checked `/Volumes/` directory:

| Mount | Type | Status |
|-------|------|--------|
| Macintosh HD | System volume | ✓ Active (symlink to /) |
| NO NAME | External/USB | ✓ Mounted (owned by leesangmin) |
| Orchestration | Custom mount | ✓ Active |
| Projects | Custom mount | ✓ Active |
| Warp | Custom mount | ✓ Active (6 items) |

No traditional NAS SMB/NFS mounts detected. Custom mounts appear to be local or application-specific.

## mDNS Discovery Results

mDNS service discovery was blocked by permission restrictions. The `dns-sd -B _ssh._tcp local` command requires elevated permissions or specific entitlements.

Manual hostname resolution showed:
- m4-air.local → 172.30.1.6 (resolved)
- m4-studio.local → 172.30.1.44 (resolved)
- mini-gateway.local → 172.30.1.42 (resolved)
- mini-build.local → NOT FOUND
- mini-util.local → NOT FOUND
- mini-media.local → NOT FOUND
- dgx-spark.local → NOT FOUND

## Recommendations

### Immediate Actions

1. **Accept SSH host keys for m4-studio and mini-gateway**
   ```bash
   ssh-keyscan -H 100.87.39.34 >> ~/.ssh/known_hosts
   ssh-keyscan -H 100.89.236.78 >> ~/.ssh/known_hosts
   ```

2. **Investigate missing minis and dgx-spark**
   - Verify physical power state
   - Check network cable connections
   - Verify Tailscale daemon is running
   - Check hostname configuration matches registry

### Network Configuration

3. **Consider Tailscale subnet routing** for machines without direct Tailscale presence
   - Configure mini-gateway as subnet router
   - Enable IP forwarding for local network access

4. **Document actual hostnames** - Several machines show mismatch:
   - Registry: "m4-studio" → Tailscale: "alive-macstudio"
   - Need to verify intended naming scheme

5. **mDNS reliability concerns**
   - mini-gateway showed high latency variance (4-102ms)
   - Consider using Tailscale IPs as primary connection method

### Monitoring

6. **Set up automated health checks**
   - Periodic ping/SSH tests
   - Alert on machine unavailability >1 hour
   - Track Tailscale peer status changes

7. **Document SSH users per machine**
   - Current registry shows mixed usage (leesangmin vs alive)
   - Standardize or document the rationale

### Security

8. **Review SSH key authentication**
   - All tested connections use BatchMode (key-based auth)
   - Verify all machines have authorized_keys configured
   - Consider certificate-based SSH authentication

## System Context

- **Discovery machine**: m1-pro (100.94.193.82)
- **Network**: Tailscale mesh VPN + local 172.30.1.0/24
- **Timestamp**: 2026-02-16 22:14 KST
- **Tool**: Claude Code autonomous network discovery
- **Scan duration**: ~3 minutes

## Next Steps

- [ ] Accept SSH host keys for m4-studio and mini-gateway
- [ ] Power on and verify mini-build, mini-util, mini-media, dgx-spark
- [ ] Test SSH connectivity to all machines after host key acceptance
- [ ] Verify Tailscale installation on all Mac Mini machines
- [ ] Update SSH_USERS registry with actual working configurations
- [ ] Schedule regular network discovery reports (daily/weekly)
