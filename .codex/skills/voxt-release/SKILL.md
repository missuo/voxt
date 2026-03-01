---
name: voxt-release
description: Local release manager for Voxt. Use when the user asks to prepare a new Voxt version, generate release notes, build artifacts, or update appcast for in-app updates.
---

# Voxt Release

## Overview

This skill executes the project-local release flow for Voxt.
It is used when the user asks to:

- prepare/release a new version
- generate release notes from git history
- run local packaging scripts
- update `updates/appcast.json`
- prepare release commits

## Quick Start

1. Confirm release target and current repository state.
2. Follow the local release flow (no auto GitHub release workflow is used).
3. Keep `CHANGELOG.md`, `build/release/artifacts/*`, and `updates/appcast.json` consistent.
4. Mandatory before build: `CHANGELOG.md` must include a new release section for the target version.
5. Create/push git tag and publish GitHub release assets when shipping.

## Required Inputs

- `VERSION`: target semantic version string, e.g. `1.2.3` (do not include `v` prefix)
- Repository should have a clean or intentional dirty working tree state depending on pre-release checks.

## Workflow

### Step 1 — Prepare changelog (mandatory)

- Open `CHANGELOG.md`.
- Follow the changelog section style currently used in the file.
- Generate notes manually from git history or with `git log`.
- Insert notes under a new version section and keep `## [Unreleased]` section for future entries.
- Do not proceed to build if changelog is not updated for the target version.

Suggested command pattern:

```bash
VERSION="1.2.3"
BASE_TAG="$(git tag --list 'v*' --sort=-v:refname | sed -n '1p')"
echo "## [${VERSION}] - $(date +%F)"
echo "### Added"
git log ${BASE_TAG:+${BASE_TAG}..HEAD} --grep='^feat\\|^add' --pretty='- %s'
echo "### Fixed"
git log ${BASE_TAG:+${BASE_TAG}..HEAD} --grep='^fix\\|^bug' --pretty='- %s'
echo "### Changed"
git log ${BASE_TAG:+${BASE_TAG}..HEAD} --grep='^refactor\\|^perf\\|^chore' --pretty='- %s'
```

### Step 2 — Build release artifacts locally

From repository root:

```bash
chmod +x scripts/release/build_release.sh scripts/release/publish_manifest.sh
scripts/release/build_release.sh 1.2.3
scripts/release/publish_manifest.sh
```

Expected outputs:

- `build/release/artifacts/Voxt-<VERSION>.app.zip`
- `build/release/artifacts/Voxt-<VERSION>.pkg`
- `build/release/artifacts/appcast.json`

### Step 3 — Update in-repo manifest

- Verify `updates/appcast.json` points to `Voxt-<VERSION>.pkg` and contains updated version/hash.

### Step 4 — Commit

- Include at least:
  - `CHANGELOG.md`
  - `updates/appcast.json`
  - optionally any required artifacts metadata

Example:

```bash
git add CHANGELOG.md updates/appcast.json
git commit -m "release: v1.2.3"
```

### Step 5 — Publish GitHub release

1. Create and push git tag:

```bash
git tag v1.2.3
git push origin v1.2.3
```

2. Publish release and upload artifacts:

```bash
gh release create v1.2.3 \
  --title "v1.2.3" \
  --notes "Release 1.2.3" \
  build/release/artifacts/Voxt-1.2.3.app.zip \
  build/release/artifacts/Voxt-1.2.3.pkg
```

If the release already exists:

```bash
gh release upload v1.2.3 \
  build/release/artifacts/Voxt-1.2.3.app.zip \
  build/release/artifacts/Voxt-1.2.3.pkg \
  --clobber
```

## Validation checklist

- Changelog update and build/manifest flow steps below have been followed.
- `CHANGELOG.md` has a new release entry for the version being released.
- Manifest URL still points to `https://raw.githubusercontent.com/hehehai/voxt/main/updates/appcast.json`.
- `AppUpdateManager` can read updated `version`, `minimumSupportedVersion`, and `downloadURL` from manifest.
- `git diff` shows no unrelated file churn after release commit.

## Allowed tools

- `Bash` for `git`, `sed`, `awk`, and release scripts.
- `Bash` for file viewing/modification commands under `scripts/` and `updates/`.
