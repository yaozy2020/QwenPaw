# QwenPaw for fnOS

![version](https://img.shields.io/badge/version-1.1.12.6-blue)

This repo packages [QwenPaw](https://github.com/agentscope-ai/QwenPaw) as a fnOS `.fpk` application.

## Repository Structure

| Path | Purpose |
|:-----|:--------|
| `manifest` | fnOS app metadata |
| `build.sh` | Package build script |
| `cmd/` | fnOS lifecycle scripts |
| `config/` | fnOS app config |
| `wizard/` | fnOS install/uninstall/upgrade wizards |
| `ui-fndesign/` | fnOS frontend customizations |
| `scripts/` | Build, audit, and install helpers |
| `ICON.PNG` / `ICON_256.PNG` | App icons |
| `app/qwenpaw/code/` | Full QwenPaw upstream source |

## Upstream Sync

The upstream QwenPaw source lives in `app/qwenpaw/code/`. To update:

```bash
cd app/qwenpaw/code
git remote set-url origin https://github.com/agentscope-ai/QwenPaw.git
git fetch origin
git rebase origin/main
```

Or replace the directory entirely with a fresh clone of the upstream repo.

## Build

```bash
./build.sh
```

Output: `dist/*.fpk`

## Notes

- `app/qwenpaw/code/` contains the complete upstream repository
- Frontend build artifacts are generated in `app/www/` during build but are not committed
- This repo only contains fnOS packaging files and the upstream source
