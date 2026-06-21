#!/bin/bash
# QwenPaw FPK 打包脚本（参考 Hermes 风格）
# 用法: bash build.sh
#   环境变量：
#     SKIP_FRONTEND=1   跳过前端构建（ui-fndesign 控制面板）
#     SKIP_CONSOLE=1    跳过 QwenPaw 官方 console 构建（必须已存在产物）
#     CONSOLE_PM=npm    强制使用 npm 构建 console（默认 npm，因为上游用 npm）

set -e

PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
STAGE="$PROJ_DIR/build/staging"
VERSION=$(grep '^version' "$PROJ_DIR/manifest" | awk -F'=' '{print $2}' | tr -d ' ')
OUTPUT="$PROJ_DIR/build/com.dustinky.qwenpaw_v${VERSION}.fpk"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}===== QwenPaw FPK v${VERSION} 打包 =====${NC}"

# [0a/6] 版本号 SSOT 同步（manifest -> README badge）
echo "[0a/6] 版本号 SSOT 同步 ..."
python3 "$PROJ_DIR/scripts/sync-version.py" || {
  echo -e "${RED}ERROR: 版本号同步失败${NC}"
  exit 1
}

# [0b/6] AUDIT_REPORT 自动生成
echo "[0b/6] AUDIT_REPORT 自动生成 ..."
python3 "$PROJ_DIR/scripts/gen-audit.py" || echo -e "${YELLOW}  警告：AUDIT_REPORT 生成失败（非致命）${NC}"

# [0c/6] preflight 一致性门禁
echo "[0c/6] preflight 一致性门禁 ..."
bash "$PROJ_DIR/scripts/preflight.sh" || {
  echo -e "${RED}ERROR: preflight 失败，请修复上述问题后重试${NC}"
  exit 1
}

# [1/6] 构建前端 UI（Vue 3 + Vite + Nuxt UI）— bun 优先
if [ "${SKIP_FRONTEND:-0}" = "1" ]; then
  echo "[1/6] 构建前端 UI ... 跳过（SKIP_FRONTEND=1）"
else
  echo "[1/6] 构建前端 UI ..."
  cd "$PROJ_DIR/ui-fndesign"

  # fnOS QwenPaw 控制台 base path（与之前 v1.1.12 修复保持一致）
  export VITE_BASE_PATH="${VITE_BASE_PATH:-/cgi/ThirdParty/com.dustinky.qwenpaw/index.cgi/}"
  echo "  VITE_BASE_PATH=$VITE_BASE_PATH"

  if [ -x "$HOME/.bun/bin/bun" ]; then
    echo "  使用 Bun 工具链"
    "$HOME/.bun/bin/bun" install --ignore-scripts
    # workaround: bun run build 在某些环境下报 CouldntReadCurrentDirectory
    "$HOME/.bun/bin/bun" ./node_modules/vite/bin/vite.js build
  elif command -v pnpm >/dev/null 2>&1; then
    echo -e "${YELLOW}  未找到 bun，回退到 pnpm${NC}"
    pnpm install --frozen-lockfile --ignore-scripts || pnpm install --ignore-scripts
    pnpm build
  elif command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}  未找到 bun/pnpm，回退到 npm${NC}"
    if [ -f package-lock.json ]; then npm ci --ignore-scripts; else npm install --ignore-scripts; fi
    npm run build
  else
    echo -e "${RED}ERROR: 未找到 bun / pnpm / npm，无法构建前端${NC}"
    exit 1
  fi

  # Vite outDir 已配置为 ../app/www，产物直接落在 app/www/，无需再 cp
  cd "$PROJ_DIR"
fi

# [1b/6] 构建 QwenPaw 官方 console（React + Vite，输出到 src/qwenpaw/console/）
CONSOLE_DEST="$PROJ_DIR/src/qwenpaw/console"
if [ "${SKIP_CONSOLE:-0}" = "1" ]; then
  echo "[1b/6] 构建 console ... 跳过（SKIP_CONSOLE=1）"
  if [ ! -f "$CONSOLE_DEST/index.html" ]; then
    echo -e "${RED}ERROR: SKIP_CONSOLE=1 但 $CONSOLE_DEST/index.html 不存在${NC}"
    exit 1
  fi
else
  echo "[1b/6] 构建 QwenPaw 官方 console ..."
  if [ ! -d "$PROJ_DIR/upstream-console" ]; then
    echo -e "${RED}ERROR: upstream-console/ 目录不存在，请先 cp 上游 console 源码${NC}"
    exit 1
  fi
  cd "$PROJ_DIR/upstream-console"
  if command -v npm >/dev/null 2>&1; then
    echo "  使用 npm（上游官方）"
    if [ ! -d node_modules ] || [ "${CONSOLE_FORCE_INSTALL:-0}" = "1" ]; then
      npm ci --no-audit --no-fund --prefer-offline 2>&1 | tail -3
    fi
    npm run build 2>&1 | tail -3
  else
    echo -e "${RED}ERROR: 未找到 npm，无法构建 console${NC}"
    exit 1
  fi
  rm -rf "$CONSOLE_DEST"
  mkdir -p "$CONSOLE_DEST"
  cp -a dist/. "$CONSOLE_DEST/"
  cd "$PROJ_DIR"
  echo "  console 产物已拷贝到 $CONSOLE_DEST"
fi

# [2/6] 准备 staging（瘦身核心：仅打包运行时必需文件）
echo "[2/6] 准备 staging ..."
rm -rf "$STAGE"
mkdir -p "$STAGE"

# 用 tar 复制大部分文件（排除源码开发目录，后面手动精简复制）
tar -cf - -C "$PROJ_DIR" \
  --exclude='build' \
  --exclude='src/qwenpaw' \
  --exclude='plugins' \
  --exclude='console' \
  --exclude='console/dist' \
  --exclude='ui-fndesign/node_modules' \
  --exclude='ui-fndesign/dist' \
  --exclude='ui-fndesign/.turbo' \
  --exclude='.git' \
  --exclude='.github' \
  --exclude='scripts' \
  --exclude='AUDIT_REPORT.md' \
  --exclude='*.fpk' \
  --exclude='*.sha256' \
  . | tar -xf - -C "$STAGE"

# 手动复制精简后的 Python 源码（仅 src/qwenpaw + plugins）
echo "  瘦身 Python 源码（仅 src/qwenpaw + plugins）..."
mkdir -p "$STAGE/src/qwenpaw" "$STAGE/plugins"
cp -a "$PROJ_DIR/src/qwenpaw" "$STAGE/src/"
cp -a "$PROJ_DIR/plugins" "$STAGE/"
# 保留 LICENSE 和上游 setup 必需的最小文件（pip install -e 需要 pyproject.toml/setup.py）
[ -f "$PROJ_DIR/pyproject.toml" ] && cp "$PROJ_DIR/pyproject.toml" "$STAGE/"
[ -f "$PROJ_DIR/setup.py" ] && cp "$PROJ_DIR/setup.py" "$STAGE/"
[ -f "$PROJ_DIR/LICENSE" ] && cp "$PROJ_DIR/LICENSE" "$STAGE/"

# 删 staging 中不该进 fpk 的文件
rm -rf "$STAGE/ui-fndesign"   # 前端源码不进 fpk，只要构建产物

# [3/6] fnpack 构建
echo "[3/6] fnpack 构建 ..."
cd "$STAGE"
fnpack build -d .

# [4/6] 产物处理（命名版本号）
echo "[4/6] 产物处理 ..."
FPK_IN_STAGE=$(ls "$STAGE"/*.fpk 2>/dev/null | head -1)
if [ -z "$FPK_IN_STAGE" ] || [ ! -f "$FPK_IN_STAGE" ]; then
  echo -e "${RED}ERROR: fnpack 产物未找到${NC}"
  exit 1
fi
mv "$FPK_IN_STAGE" "$OUTPUT"

# [5/6] 计算 SHA256
echo "[5/6] 计算 SHA256 ..."
sha256sum "$OUTPUT" > "${OUTPUT}.sha256"

# [6/6] 完成
echo ""
echo -e "${GREEN}===== 打包完成 =====${NC}"
echo "输出: $OUTPUT"
ls -lh "$OUTPUT"
echo ""
echo "SHA256:"
cat "${OUTPUT}.sha256"
