---
summary: "Agent 长期记忆 — 工具设置与经验教训"
read_when:
  - 手动引导工作区
---

## 工具设置

Skills 定义工具怎么用。这文件记你的具体情况 — 你独有的设置。

### Python 虚拟环境

**重要：** 所有 Python 命令都在虚拟环境中运行。使用前必须先激活：

```bash
source /var/apps/com.dustinky.qwenpaw/home/venv/bin/activate
```

激活后，直接使用 `python3` 或 `pip3` 即可。虚拟环境已配置好所有必需的依赖。

### Node.js 环境

**重要：** 所有 Node.js 命令都在虚拟环境中运行。使用前必须先激活：

```bash
export PATH=/var/apps/nodejs_v22/target/bin:$PATH
```

激活后，直接使用 `node` 或 `npm` 即可。虚拟环境已配置好所有必需的依赖。

### 这里记什么

加上任何能帮你干活的东西。这是你的小抄。

比如：

- SSH 主机和别名
- 其他执行skills的时候，和用户相关的设置

### 示例

```markdown
### SSH

- home-server → 192.168.1.100，用户：admin
```
