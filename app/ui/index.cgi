#!/bin/bash

# 脚本名称: index.cgi
# 　　版本: 1.1.0 (v1.1.12.5 安全加固)
# 原作者: FNOSP/xieguanru, FNOSP/MR_XIAOBO
# 　许可证: MIT
# 修改: v1.1.12.5 替换 grep '..' 为 realpath + startswith 真实校验，
#       URL 解码 + 拒绝符号链接逃逸，防止 path traversal。

set -u

BASE_PATH="/var/apps/com.dustinky.qwenpaw/target/www"

# 1. 从 REQUEST_URI 里拿到 index.cgi 后面的路径
URI_NO_QUERY="${REQUEST_URI%%\?*}"

REL_PATH="/"
case "$URI_NO_QUERY" in
    *index.cgi*)
        REL_PATH="${URI_NO_QUERY#*index.cgi}"
        ;;
esac

# 默认页
if [ -z "$REL_PATH" ] || [ "$REL_PATH" = "/" ]; then
    REL_PATH="/index.html"
fi

# URL 解码（处理 %2e%2e 等编码绕过）
url_decode() {
    local data="${1//+/ }"
    printf '%b' "${data//%/\\x}"
}
DECODED_REL=$(url_decode "${REL_PATH}")

# 拼出真实文件路径
TARGET_FILE="${BASE_PATH}${DECODED_REL}"

# 解析为绝对路径（resolves .. and symlinks）
RESOLVED=$(readlink -f -- "${TARGET_FILE}" 2>/dev/null)
BASE_RESOLVED=$(readlink -f -- "${BASE_PATH}" 2>/dev/null)

bad_request() {
    echo "Status: 400 Bad Request"
    echo "Content-Type: text/plain; charset=utf-8"
    echo ""
    echo "Bad Request"
    exit 0
}

not_found() {
    echo "Status: 404 Not Found"
    echo "Content-Type: text/plain; charset=utf-8"
    echo ""
    echo "404 Not Found"
    exit 0
}

# 解析失败 → 文件不存在
if [ -z "${RESOLVED}" ] || [ -z "${BASE_RESOLVED}" ]; then
    not_found
fi

# 强制路径必须在 BASE_PATH 之下（防 path traversal + symlink 逃逸）
case "${RESOLVED}" in
    "${BASE_RESOLVED}"|"${BASE_RESOLVED}"/*)
        : # ok
        ;;
    *)
        bad_request
        ;;
esac

# 文件必须存在且为常规文件
if [ ! -f "${RESOLVED}" ]; then
    not_found
fi

# 3. 根据扩展名简单判断 Content-Type
ext="${RESOLVED##*.}"
case "$ext" in
    html|htm) mime="text/html; charset=utf-8" ;;
    css)      mime="text/css; charset=utf-8" ;;
    js|mjs)   mime="application/javascript; charset=utf-8" ;;
    json)     mime="application/json; charset=utf-8" ;;
    jpg|jpeg) mime="image/jpeg" ;;
    png)      mime="image/png" ;;
    gif)      mime="image/gif" ;;
    svg)      mime="image/svg+xml" ;;
    woff)     mime="font/woff" ;;
    woff2)    mime="font/woff2" ;;
    ttf)      mime="font/ttf" ;;
    txt|log)  mime="text/plain; charset=utf-8" ;;
    *)        mime="application/octet-stream" ;;
esac

# 4. 输出头 + 文件内容
echo "Content-Type: $mime"
echo "X-Content-Type-Options: nosniff"
echo ""
cat -- "${RESOLVED}"
