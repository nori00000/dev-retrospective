---
type: documentation
aliases:
  - "System Inventory M1 Pro 2026-02-17"
author: "[[Claude Code]]"
date created: 2026-02-17
date modified: 2026-02-17
tags:
  - homelab
  - inventory
  - hardware
  - software
CMDS: "[[907 Technology & Development Division]]"
index: "[[Session Logs]]"
status: complete
machine: m1-pro
agent: claude-code
---
# System Inventory: M1 Pro MacBook Pro
**Inventory Date:** 2026-02-17
**Status:** Complete
**Scope:** Hardware, Software, Development Tools, Applications

---

## 1. Hardware Overview

| Component | Details |
|-----------|---------|
| **Model Name** | MacBook Pro |
| **Model Identifier** | MacBookPro18,3 |
| **Model Number** | MKGQ3KH/A |
| **Processor** | Apple M1 Pro |
| **Cores** | 10 total (8 Performance + 2 Efficiency) |
| **Memory (RAM)** | 16 GB (17,179,869,184 bytes) |
| **Serial Number** | QFV000Q7R0 |
| **Hardware UUID** | B3219CEC-6839-520E-8135-44A23D746BF7 |
| **System Firmware** | 13822.81.10 |
| **OS Loader Version** | 13822.81.10 |
| **Activation Lock** | Disabled |

---

## 2. macOS Version

| Property | Value |
|----------|-------|
| **Product Name** | macOS |
| **Version** | 26.3 |
| **Build Version** | 25D125 |
| **Kernel** | Darwin 25.3.0 |
| **Architecture** | arm64 (ARM64_T6000) |

**System Info:**
```
Darwin m1-pro 25.3.0 Darwin Kernel Version 25.3.0: Wed Jan 28 20:53:15 PST 2026; root:xnu-12377.81.4~5/RELEASE_ARM64_T6000 arm64
```

---

## 3. Disk Usage

| Filesystem | Size | Used | Available | Capacity | Mount Point |
|-----------|------|------|-----------|----------|-------------|
| Main Drive (disk3s1s1) | 926 GB | 11 GB | 574 GB | 2% | / |
| VM (disk3s6) | 926 GB | 15 GB | 574 GB | 3% | /System/Volumes/VM |
| Preboot (disk3s2) | 926 GB | 7.8 GB | 574 GB | 2% | /System/Volumes/Preboot |
| Update (disk3s4) | 926 GB | 11 MB | 574 GB | 1% | /System/Volumes/Update |
| Data (disk3s5) | 926 GB | 316 GB | 574 GB | 36% | /System/Volumes/Data |
| External: Warp | 333 MB | 295 MB | 38 MB | 89% | /Volumes/Warp |
| External: NO NAME | 29 GB | 5.5 GB | 23 GB | 20% | /Volumes/NO NAME |

**Storage Summary:**
- Total main drive capacity: 926 GB
- Total used: ~349 GB across all volumes
- Primary data partition utilization: 36% of 926 GB

---

## 4. Memory Statistics

**System Memory:**
- **Total RAM:** 16 GB
- **Uptime:** 1 day, 1 hour, 40 minutes
- **Load Averages:** 5.66 5.65 5.83 (current, 5-min, 15-min)

**Active Users:** 5

---

## 5. Homebrew Packages

### Package Counts
- **Formula (CLI tools):** 114 packages
- **Cask (Applications):** 4 packages

### Homebrew Formula Packages (114 total)

	aom
	autoconf
	awscli
	brotli
	ca-certificates
	cairo
	cfitsio
	cgif
	fftw
	fontconfig
	freetype
	fribidi
	fswatch
	gcc
	gdk-pixbuf
	gettext
	gh
	giflib
	glib
	gmp
	gnupg
	gnutls
	gpgme
	gpgmepp
	graphite2
	harfbuzz
	hdf5
	highway
	hwloc
	icu4c@78
	imagemagick
	imath
	isl
	jasper
	jpeg-turbo
	jpeg-xl
	libaec
	libarchive
	libassuan
	libb2
	libdatrie
	libde265
	libdeflate
	libdicom
	libevent
	libexif
	libgcrypt
	libgpg-error
	libheif
	libidn2
	libimagequant
	libksba
	libmatio
	libmpc
	libnghttp2
	libomp
	libpng
	libraw
	librsvg
	libtasn1
	libthai
	libtiff
	libtool
	libultrahdr
	libunistring
	libusb
	libvmaf
	libx11
	libxau
	libxcb
	libxdmcp
	libxext
	libxml2
	libxrender
	libyaml
	little-cms2
	lz4
	lzo
	m4
	mozjpeg
	mpdecimal
	mpfr
	nettle
	npth
	nspr
	nss
	open-mpi
	openexr
	openjpeg
	openjph
	openslide
	openssl@3
	p11-kit
	pango
	pcre2
	pinentry
	pixman
	pkgconf
	pmix
	poppler
	python@3.13
	rbenv
	readline
	ruby-build
	shared-mime-info
	sqlite
	unbound
	uthash
	vips
	webp
	x265
	xorgproto
	xz
	zstd

### Homebrew Cask Applications (4 total)

	iterm2
	powershell
	rectangle
	tailscale-app

---

## 6. HomeIab Daemons

No HomeIab-specific daemons currently registered in launchctl.

---

## 7. Development Tools

### Language Versions
- **Node.js:** v22.14.0
- **Python:** Python 3.13.4
- **Go:** Not found (exit code 127)
- **Rust:** Not found (exit code 127)

### Key Development Tools Installed (via Homebrew)
- GCC (GNU Compiler Collection)
- rbenv (Ruby version manager)
- ruby-build
- fswatch (file system watcher)
- GitHub CLI (gh)
- AWS CLI (awscli)
- AWS-related: open-mpi, pmix, hwloc

---

## 8. Installed Applications (Partial List)

### Creative & Media
	Adobe Acrobat DC
	Adobe Creative Cloud
	Compressor.app
	Final Cut Pro.app
	GarageBand.app
	iMovie.app
	Logic Pro.app
	Motion.app
	CapCut.app
	OBS.app

### Development & Code
	Android Studio.app
	Cursor.app
	GitHub Desktop.app
	iTerm.app
	OpenCode.app
	Visual Studio Code (implied)
	LM Studio.app

### Productivity & Office
	Keynote.app
	Numbers.app
	Pages.app
	Microsoft Word.app
	Microsoft Excel.app
	Microsoft PowerPoint.app
	Microsoft Outlook.app
	Microsoft Teams.app
	Microsoft OneNote.app
	Obsidian.app
	UlyssesMac.app
	Notability.app
	GoodNotes.app

### Communication
	KakaoTalk.app
	Telegram.app
	zoom.us.app
	Microsoft Teams.app

### Browsers
	Google Chrome.app
	Microsoft Edge.app
	Safari.app

### Utilities & Tools
	CleanShot X.app
	Docker.app
	Raycast.app
	Rectangle.app
	Rectangle Pro 3.57.dmg
	RunCat.app
	Shottr.app
	The Unarchiver.app
	Tailscale.app
	Synology Drive Client.app
	OneDrive.app
	Warp.app

### Gaming & Entertainment
	Battle.net.app
	StarCraft
	Steam (implied)

### AI & ML
	ChatGPT.app
	ChatGPT Atlas.app
	Claude.app
	Ollama.app
	GPT4All.app
	LM Studio.app
	Pinokio.app

### Other Notable Apps
	AhnLab (Security)
	AlDente.app (Power management)
	Android File Transfer.app
	Eagle.app (Content curation)
	Jump Desktop.app & Jump Desktop Connect.app (Remote desktop)
	Hookmark.app (Link management)
	Highlights.app
	Plaud.app
	Screaming Frog SEO Spider.app
	Hancom Office HWP.app
	Dia.app (Diagramming)
	PowerShell.app
	Trae.app
	Delfino
	Gobi Desktop 3.app
	Comet.app

---

## 9. System Uptime

- **Current Time:** 22:13
- **Uptime:** 1 day, 1 hour, 40 minutes
- **Active Sessions:** 5 users
- **Load Averages:** 5.66 (current), 5.65 (5-min), 5.83 (15-min)

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Homebrew Formulas** | 114 |
| **Homebrew Casks** | 4 |
| **Total Apps in /Applications** | 90+ |
| **Development Languages** | 2 active (Node.js, Python) |
| **CPU Cores** | 10 (8P+2E) |
| **RAM** | 16 GB |
| **Storage Capacity** | 926 GB |
| **Current Data Usage** | 36% (316 GB) |

---

## Notes

- System is actively in use with moderate load (5.66-5.83)
- Comprehensive development environment with multiple IDEs and languages
- Extensive creative software stack (Adobe, Final Cut Pro, Logic Pro)
- Well-equipped with AI/ML tools (ChatGPT, Claude, Ollama, LM Studio, GPT4All)
- Good battery management setup (AlDente installed)
- Remote desktop capability configured (Jump Desktop)
- External storage active on two devices (Warp and NO NAME volumes)
- Go and Rust toolchains not currently installed
- Network connectivity tools present (Tailscale, Docker)

---

**Inventory completed:** 2026-02-17
**Compiled by:** Claude Code
**Format:** Markdown with YAML frontmatter
**Tags:** #homelab #inventory #m1-pro #macos
