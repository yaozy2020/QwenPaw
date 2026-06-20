# QwenPaw for fnOS — yaozy 二次打包版

[![Version](https://img.shields.io/badge/version-1.1.12.5-blue)](https://github.com/yaozy2020/QwenPaw/releases)
[![License](https://img.shields.io/badge/license-Apache%202.0-green)](LICENSE)
[![fnOS](https://img.shields.io/badge/fnOS-%E2%89%A5%200.9.21-orange)](https://www.fnnas.com/)

> ⚠️ **重要说明：本仓库仅为个人自用的二次打包，不对外提供任何形式的支持与保障。**
>
> - **原 fpk 打包项目**：[naspk-com/QwenPaw](https://github.com/naspk-com/QwenPaw)（dustinky 的飞牛 fpk 版本）
> - **官方源码项目**：[agentscope-ai/QwenPaw](https://github.com/agentscope-ai/QwenPaw)（AgentScope 团队）
> - **本仓库目的**：在原 fpk 基础上进行个人定制（同步官方最新版本、移除部分功能、修复回调脚本等），仅供自己飞牛 NAS 使用。
> - **使用风险自负**：未经充分测试，不保证稳定性，不接受 issue/PR，请优先使用上述两个原项目。

---

## 与原项目的差异

相对于 [naspk-com/QwenPaw](https://github.com/naspk-com/QwenPaw) v1.1.11，本仓库的修改：

### v1.1.12 → v1.1.12.1 变更

| # | 文件 | 改动 | 类型 |
|:--|:-----|:-----|:-----|
| B1 | `cmd/config_callback` | `QWENPAAW_LOG_LEVEL` → `QWENPAW_LOG_LEVEL`（环境变量名 typo） | Bug 修复 |
| B2 | `cmd/install_callback` | `handle_error`（未定义函数）→ `exit 1` + `log_msg`，删除 `ERROR_MSG` | Bug 修复 |
| B2 | `cmd/upgrade_callback` | 同上 | Bug 修复 |
| S1 | `cmd/upgrade_callback` | `kill -TERM` / `kill -KILL` 补 `2>/dev/null \|\| true` | 规范 |
| S2 | `cmd/install_callback` `cmd/upgrade_callback` | `cd "${CODE_DIR}"` 补 `\|\| exit 1` | 规范 |
| S3 | `cmd/upgrade_callback` | 补 `chmod -R 755 "${TRIM_PKGVAR}"` 和 `"${TRIM_PKGETC}"` | 规范 |
| S4 | `app/ui/api.cgi` | 三处启动命令补 `QWENPAW_LOG_LEVEL=info` | 规范 |
| S5 | `cmd/install_init` | 末尾补换行 | 规范 |
| S6 | `app/www/` | 删除 5 个无关图片（bilibili/donate/douyin/wechat），favicon 替换为 QwenPaw 图标 | 清理 |
| S7 | `build/` | 从 git 移除 + `.gitignore` 加 `build/` | 清理 |

### v1.1.11 → v1.1.12 变更

| 项 | 改动 |
|:---|:---|
| QwenPaw 版本 | 同步至上游官方 [v1.1.12](https://github.com/agentscope-ai/QwenPaw/releases) |
| Cloudflare Tunnel | 控制台移除"外网访问"入口（仅删 UI 导航，未动 Python 后端模块） |
| 配置回调脚本 | 重写为标准 bash 脚本（kill PID → 重启 venv 进程） |
| 控制台 UI base path | 修正为 `/cgi/ThirdParty/com.dustinky.qwenpaw/index.cgi/`（修复白屏） |
| 发布者 | yaozy（distributor 字段） |

---

## 简介（来自上游官方）

QwenPaw 是一款部署在你自己的 NAS 上的个人 AI 助理。它不只是聊天机器人 — 你可以通过微信、QQ、钉钉、飞书、Discord、Telegram 等多通道与它交互，配置定时任务让它自动执行工作，通过 Skills 无限扩展它的能力。所有数据完全存储在本地，无需依赖任何第三方云服务。

由 [AgentScope](https://github.com/agentscope-ai) 团队基于 AgentScope、AgentScope Runtime 与 ReMe 构建，支持本地大模型完全离线运行。

## 核心功能

- **多通道对话** — 支持微信、QQ、钉钉、飞书、Discord、Telegram、iMessage 等
- **多智能体协作** — 独立配置多个 Agent，互相通信协作完成复杂任务
- **定时任务** — Cron 定时让 QwenPaw 自动执行工作
- **Skills 扩展** — 能力由 Skills 决定，可无限扩展
- **本地优先** — 支持 Ollama 等本地大模型，完全离线也能工作
- **多层安全防护** — 沙箱执行、会话隔离、权限控制

## 安装（仅供个人参考）

### 前置要求

- 飞牛 NAS 系统 **≥ 0.9.21**
- 如需使用内置 Ollama 驱动，请先在飞牛应用商店安装 **Ollama** 应用

### 步骤

1. 从 [Releases](https://github.com/yaozy2020/QwenPaw/releases) 下载最新 `.fpk`
2. 飞牛应用商店选择「手动安装」上传 fpk
3. 安装过程中选择日志级别（默认 `info`）
4. 等待安装完成（55% 附近会停留较久属正常现象）

安装完成后会同时提供两个入口：
- **飞牛桌面图标 → QwenPaw**：上游官方 React 控制台（端口 19091，iframe）
- **飞牛桌面图标 → QwenPaw 控制台**：fnOS 集成的应用管理面板（启停/重启/日志/版本）

## 项目结构

```
com.dustinky.qwenpaw/
├── app/
│   ├── qwenpaw/code/        # QwenPaw 官方源码（v1.1.12）
│   ├── ui/                   # API 网关 (api.cgi) 和 Web UI 代理 (index.cgi)
│   └── www/                  # ui-fndesign 构建产物（Vue/Nuxt UI）
├── ui-fndesign/              # 飞牛集成管理面板源码（Vue 3 + Nuxt UI）
├── cmd/                      # 安装/升级/卸载/配置/启停回调脚本
├── config/resource           # 数据共享目录权限配置
├── wizard/                   # 安装向导
├── manifest                  # fnOS 应用清单
└── build.sh                  # fnpack 打包脚本
```

## 构建方法（自用记录）

```bash
# 1. 构建 React 控制台（QwenPaw 官方控制台）
cd app/qwenpaw/code/console
npm ci && npm run build
mkdir -p ../src/qwenpaw/console
cp -R dist/. ../src/qwenpaw/console/
rm -rf node_modules dist

# 2. 构建 Vue 控制台（fnOS 集成面板，必须传 base path）
cd ../../../ui-fndesign
VITE_BASE_PATH="/cgi/ThirdParty/com.dustinky.qwenpaw/index.cgi/" npm run build
rm -rf node_modules

# 3. 用 fnpack 官方工具打包
cd ..
fnpack build -d .
```

⚠️ **打包要点**：
- ICON 文件名必须大写（`ICON.PNG`、`ICON_256.PNG`）
- `manifest` 中 `desktop_applaunchname` 与 `app/ui/config` 中的 `.url` key 必须一致（都是 `com.dustinky.qwenpaw.Application`）
- 不要手动 `tar czf`，必须用 `fnpack build`

## 版本历史

### v1.1.12.2

- 彻底移除 Cloudflare Tunnel 后端代码（`tunnel/` 目录 3 文件）
- 移除 Voice Channel (Twilio) 后端代码（`app/channels/voice/` 6 文件 + `app/routers/voice.py`）
- 清理所有共享文件中的 voice/tunnel 引用（registry、schema、config、cli 等 8 个文件）
- 清理相关测试文件（unit/integration/contract 共 5 文件）
- Python 语法验证全部通过，其他 channel 功能不受影响

### v1.1.12.1

- 修复 `config_callback` 中环境变量名 typo（`QWENPAAW_LOG_LEVEL` → `QWENPAW_LOG_LEVEL`）
- 修复 `install_callback` / `upgrade_callback` 中调用未定义函数 `handle_error` 导致 pip 安装失败时脚本不退出、误报成功
- `upgrade_callback` 的 `kill` 命令补 `|| true`，防止进程已退出时返回非零
- `upgrade_callback` 补齐 `chmod TRIM_PKGVAR` / `chmod TRIM_PKGETC`
- `api.cgi` 三处启动命令补 `QWENPAW_LOG_LEVEL=info`
- 删除 `app/www/` 中 5 个无关图片，favicon 替换为 QwenPaw 图标
- `build/` 产物从 git 移除，`.gitignore` 补 `build/`

### v1.1.12

- 同步上游官方 v1.1.12（前端从 Vue 改为 React，源码在 `app/qwenpaw/code/console/`）
- 移除 Cloudflare Tunnel 一键穿透功能（控制台导航入口）
- 修复配置回调脚本（kill 旧 PID → venv 启动新进程）
- 修复控制台白屏（base path 必须指向 CGI 代理路径）
- 发布者改为 yaozy

## 相关链接

| 项目 | 地址 |
|:---|:---|
| **官方源码项目** | [agentscope-ai/QwenPaw](https://github.com/agentscope-ai/QwenPaw) |
| **原 fpk 打包项目** | [naspk-com/QwenPaw](https://github.com/naspk-com/QwenPaw) |
| 飞牛 NAS 官网 | [fnnas.com](https://www.fnnas.com/) |
| AgentScope 团队 | [agentscope-ai](https://github.com/agentscope-ai) |

## 许可证

基于 [Apache-2.0](LICENSE) 许可证开源（与上游一致）。

本仓库为个人学习和自用目的对原 fpk 的二次修改，**所有版权归 AgentScope 团队及原打包者所有**，本仓库不主张任何独立著作权。
