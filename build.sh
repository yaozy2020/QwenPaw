#!/bin/bash
# QwenPaw FPK 打包脚本
set -e

PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJ_DIR/build"
OUTPUT="$PROJ_DIR/qwenpaw.fpk"

echo "===== QwenPaw FPK 打包 ====="

# 1. 准备 build 目录
echo "[1/5] 准备 build 目录 ..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 2. 打包 app.tgz
echo "[2/5] 打包 app.tgz ..."
cd "$PROJ_DIR"
tar czf "$BUILD_DIR/app.tgz" app

# 3. 计算 checksum
echo "[3/5] 计算 checksum ..."
CHECKSUM=$(md5sum "$BUILD_DIR/app.tgz" | awk '{print $1}')
echo "  checksum = $CHECKSUM"

# 4. 复制文件
echo "[4/5] 复制文件 ..."
cp "$PROJ_DIR/manifest" "$BUILD_DIR/"
cp "$PROJ_DIR/ICON.png" "$BUILD_DIR/"
cp "$PROJ_DIR/ICON_256.png" "$BUILD_DIR/"
cp -a "$PROJ_DIR/cmd" "$BUILD_DIR/"
cp -a "$PROJ_DIR/config" "$BUILD_DIR/"
cp -a "$PROJ_DIR/wizard" "$BUILD_DIR/"

# 更新 manifest 中的 checksum
sed -i "s/^checksum.*/checksum              = $CHECKSUM/" "$BUILD_DIR/manifest" || true

# 5. 打包 fpk
echo "[5/5] 打包 fpk ..."
cd "$BUILD_DIR"
tar czf "$OUTPUT" manifest ICON.png ICON_256.png app.tgz cmd config wizard
cd "$PROJ_DIR"

echo ""
echo "===== 打包完成 ====="
echo "输出: $OUTPUT"
ls -lh "$OUTPUT"
echo ""
echo "fpk 内容:"
tar tzf "$OUTPUT"
