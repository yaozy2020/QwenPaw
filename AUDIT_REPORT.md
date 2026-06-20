# QwenPaw FPK — 审计报告

> ⚠️ 本文件由 `scripts/gen-audit.py` 自动生成，请勿手工编辑。
> 数据源：manifest / cmd / wizard / app / .github / git tags。

## 当前版本：v1.1.12.5

- **生成时间**：2026-06-21 02:27:05 +0800
- **应用名**：com.dustinky.qwenpaw
- **显示名**：QwenPaw
- **依赖**：nodejs_v24:python312
- **服务端口**：19091
- **fnOS 最低版本**：0.9.21

## 工程统计

| 项目 | 数据 |
|:-----|:-----|
| 生命周期脚本 | 9 个 |
| 向导清单 | 4 个 |
| 上游 Python 文件 | 526 个，176,246 行 |
| 上游 Plugins | 50 个 .py |
| CI Workflow | 2 个 |

## 生命周期脚本清单

| 脚本 | 说明 |
|:-----|:-----|
| `cmd/config_callback` | 配置变更后回调（fnOS 控制台修改配置时触发） |
| `cmd/config_init` | 配置初始化 |
| `cmd/install_callback` | 安装完成回调 |
| `cmd/install_init` | 安装前环境检查 |
| `cmd/main` | 应用启动 / stop / status 入口 |
| `cmd/uninstall_callback` | 卸载完成回调 |
| `cmd/uninstall_init` | 卸载前清理 |
| `cmd/upgrade_callback` | 升级完成回调 |
| `cmd/upgrade_init` | 升级前环境检查 |

## 向导清单

| 文件 | 阶段 |
|:-----|:-----|
| `wizard/config` | config |
| `wizard/install` | install |
| `wizard/uninstall` | uninstall |
| `wizard/upgrade` | upgrade |

## CI/CD

| Workflow | 触发 |
|:---------|:-----|
| `ci.yml` | PR 触发，跑 preflight + 前端构建验证 |
| `release.yml` | tag 触发，fnpackup 容器构建并自动上传 Release |

## 最近发布记录

| 版本 | 发布日期 |
|:-----|:----:|
| `v1.1.12.3` | 2026-06-20 |
| `v1.1.12.2` | 2026-06-18 |
| `v1.1.12.1` | 2026-06-18 |
| `v1.1.12` | 2026-06-18 |

---

生成命令：`python3 scripts/gen-audit.py`
