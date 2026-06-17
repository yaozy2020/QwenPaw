#!/bin/bash
# QwenPaw FPK 打包脚本（使用 fnpack）
# 用法: bash build.sh

set -e

PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$PROJ_DIR/com.dustinky.qwenpaw.fpk"

echo "===== QwenPaw FPK 打包 ====="

# 确认 www/ 已存在（Vue UI 构建产物）
if [ ! -d "$PROJ_DIR/app/www" ]; then
    echo "错误: app/www/ 不存在！请先构建 Vue UI"
    exit 1
fi

# 用 fnpack 构建 fpk
echo "[1/3] fnpack 验证并打包 ..."
cd "$PROJ_DIR"
fnpack build -d .

echo ""
echo "===== 打包完成 ====="
echo "输出: $OUTPUT"
ls -lh "$OUTPUT"
echo ""
echo "fpk 内容:"
tar tzf "$OUTPUT"