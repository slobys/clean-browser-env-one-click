#!/bin/sh
set -eu

REPO="slobys/clean-browser-env-one-click"
BRANCH="${BRANCH:-main}"
TMP_DIR="${TMPDIR:-/tmp}/clean-browser-env-one-click"
SCRIPT="$TMP_DIR/scripts/unix/clean-browser-env.sh"
FINGERPRINT_PAGE="$TMP_DIR/assets/fingerprint-test.html"

log() {
    printf '%s\n' "==> $*"
}

die() {
    printf '%s\n' "[ERROR] $*" >&2
    exit 1
}

download() {
    url="$1"
    out="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --retry 3 --connect-timeout 15 "$url" -o "$out" && return 0
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -qO "$out" "$url" && return 0
    fi
    return 1
}

prepare_script() {
    mkdir -p "$(dirname "$SCRIPT")"
    if [ -f "./scripts/unix/clean-browser-env.sh" ]; then
        SCRIPT="./scripts/unix/clean-browser-env.sh"
        return 0
    fi

    url="https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/unix/clean-browser-env.sh"
    log "下载脚本: $url"
    download "$url" "$SCRIPT" || die "下载失败，请检查网络或手动 clone 项目"
    chmod +x "$SCRIPT"

    mkdir -p "$(dirname "$FINGERPRINT_PAGE")"
    asset_url="https://raw.githubusercontent.com/$REPO/$BRANCH/assets/fingerprint-test.html"
    download "$asset_url" "$FINGERPRINT_PAGE" || die "下载指纹测试页失败，请检查网络或手动 clone 项目"
}

usage() {
    cat <<'EOF_USAGE'
用法:
  sh bootstrap.sh
  sh bootstrap.sh start
  sh bootstrap.sh fingerprint
  sh bootstrap.sh doctor
  sh bootstrap.sh list
  sh bootstrap.sh cleanup

说明:
  默认打开菜单。所有临时资料只写入 ~/CleanBrowserEnv。
EOF_USAGE
}

menu() {
    while :; do
        cat <<'EOF_MENU'

Clean Browser Env
1. 启动干净浏览器环境
2. 打开本地指纹测试页
3. 环境检查
4. 查看已创建的临时 Profile
5. 清理本工具创建的临时 Profile
0. 退出
EOF_MENU
        printf '请选择: '
        read ans || exit 0
        case "$ans" in
            1) sh "$SCRIPT" start ;;
            2) sh "$SCRIPT" fingerprint ;;
            3) sh "$SCRIPT" doctor ;;
            4) sh "$SCRIPT" list ;;
            5) sh "$SCRIPT" cleanup ;;
            0) exit 0 ;;
            *) printf '%s\n' "无效选择" ;;
        esac
    done
}

prepare_script

case "${1:-menu}" in
    menu) menu ;;
    start|fingerprint|doctor|list|cleanup) sh "$SCRIPT" "$@" ;;
    -h|--help|help) usage ;;
    *) die "未知参数: $1" ;;
esac
