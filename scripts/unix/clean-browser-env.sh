#!/bin/sh
set -eu

APP_HOME="${CLEAN_ENV_HOME:-$HOME/CleanBrowserEnv}"
PROFILE_ROOT="$APP_HOME/profiles"
DEFAULT_URL="${CLEAN_ENV_URL:-about:blank}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"
FINGERPRINT_PAGE="${CLEAN_ENV_FINGERPRINT_PAGE:-$PROJECT_ROOT/assets/fingerprint-test.html}"

log() {
    printf '%s\n' "==> $*"
}

warn() {
    printf '%s\n' "[WARN] $*" >&2
}

die() {
    printf '%s\n' "[ERROR] $*" >&2
    exit 1
}

usage() {
    cat <<'EOF_USAGE'
用法:
  sh clean-browser-env.sh start [--browser auto|chrome|edge|firefox] [--url URL]
  sh clean-browser-env.sh fingerprint [--browser auto|chrome|edge|firefox] [--simulate]
  sh clean-browser-env.sh doctor
  sh clean-browser-env.sh list
  sh clean-browser-env.sh cleanup [--yes]

说明:
  start   创建一次性浏览器 Profile 并启动浏览器
  fingerprint 创建一次性 Profile 并打开本地指纹测试页；--simulate 会展开本地模拟面板
  doctor  检查本机可用浏览器
  list    列出本工具创建的临时 Profile
  cleanup 只清理 ~/CleanBrowserEnv/profiles 下的临时 Profile
EOF_USAGE
}

browser_exists() {
    name="$1"
    case "$name" in
        chrome)
            command -v google-chrome >/dev/null 2>&1 ||
            command -v google-chrome-stable >/dev/null 2>&1 ||
            command -v chromium >/dev/null 2>&1 ||
            command -v chromium-browser >/dev/null 2>&1 ||
            [ -d "/Applications/Google Chrome.app" ]
            ;;
        edge)
            command -v microsoft-edge >/dev/null 2>&1 ||
            command -v microsoft-edge-stable >/dev/null 2>&1 ||
            [ -d "/Applications/Microsoft Edge.app" ]
            ;;
        firefox)
            command -v firefox >/dev/null 2>&1 ||
            [ -d "/Applications/Firefox.app" ]
            ;;
        *)
            return 1
            ;;
    esac
}

pick_browser() {
    requested="$1"
    if [ "$requested" != "auto" ]; then
        browser_exists "$requested" || die "未找到浏览器: $requested"
        printf '%s\n' "$requested"
        return 0
    fi

    for item in chrome edge firefox; do
        if browser_exists "$item"; then
            printf '%s\n' "$item"
            return 0
        fi
    done
    die "未找到 Chrome / Edge / Firefox，请先安装其中一个浏览器"
}

make_profile_dir() {
    mkdir -p "$PROFILE_ROOT"
    id="$(date '+%Y%m%d-%H%M%S')"
    profile="$PROFILE_ROOT/session-$id"
    mkdir -p "$profile"
    printf '%s\n' "$profile"
}

launch_macos() {
    browser="$1"
    profile="$2"
    url="$3"

    case "$browser" in
        chrome)
            open -na "Google Chrome" --args --user-data-dir="$profile" --no-first-run --disable-sync --disable-extensions --new-window "$url"
            ;;
        edge)
            open -na "Microsoft Edge" --args --user-data-dir="$profile" --no-first-run --disable-sync --disable-extensions --new-window "$url"
            ;;
        firefox)
            open -na "Firefox" --args -profile "$profile" -no-remote -new-instance "$url"
            ;;
    esac
}

find_linux_bin() {
    for bin in "$@"; do
        if command -v "$bin" >/dev/null 2>&1; then
            printf '%s\n' "$bin"
            return 0
        fi
    done
    return 1
}

launch_linux() {
    browser="$1"
    profile="$2"
    url="$3"

    case "$browser" in
        chrome)
            bin="$(find_linux_bin google-chrome google-chrome-stable chromium chromium-browser)" || die "未找到 Chrome/Chromium"
            nohup "$bin" --user-data-dir="$profile" --no-first-run --disable-sync --disable-extensions --new-window "$url" >/dev/null 2>&1 &
            ;;
        edge)
            bin="$(find_linux_bin microsoft-edge microsoft-edge-stable)" || die "未找到 Microsoft Edge"
            nohup "$bin" --user-data-dir="$profile" --no-first-run --disable-sync --disable-extensions --new-window "$url" >/dev/null 2>&1 &
            ;;
        firefox)
            bin="$(find_linux_bin firefox)" || die "未找到 Firefox"
            nohup "$bin" -profile "$profile" -no-remote -new-instance "$url" >/dev/null 2>&1 &
            ;;
    esac
}

start_env() {
    requested="auto"
    url="$DEFAULT_URL"

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --browser)
                shift
                requested="${1:-auto}"
                ;;
            --url)
                shift
                url="${1:-about:blank}"
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                die "未知参数: $1"
                ;;
        esac
        shift
    done

    browser="$(pick_browser "$requested")"
    profile="$(make_profile_dir)"
    {
        printf 'created_at=%s\n' "$(date -Iseconds 2>/dev/null || date)"
        printf 'browser=%s\n' "$browser"
        printf 'url=%s\n' "$url"
    } > "$profile/metadata.txt"

    log "Profile: $profile"
    log "Browser: $browser"
    case "$(uname -s)" in
        Darwin) launch_macos "$browser" "$profile" "$url" ;;
        Linux) launch_linux "$browser" "$profile" "$url" ;;
        *) die "当前系统暂不支持: $(uname -s)" ;;
    esac
    log "已启动。原有浏览器资料不会被修改。"
}

fingerprint_test() {
    requested="auto"
    simulate=0

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --browser)
                shift
                requested="${1:-auto}"
                ;;
            --simulate)
                simulate=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                die "未知参数: $1"
                ;;
        esac
        shift
    done

    [ -f "$FINGERPRINT_PAGE" ] || die "未找到指纹测试页: $FINGERPRINT_PAGE"
    page_url="$FINGERPRINT_PAGE"
    if [ "$simulate" -eq 1 ]; then
        case "$page_url" in
            file://*) page_url="${page_url}?simulate=1" ;;
            /*) page_url="file://$(printf '%s' "$page_url" | sed 's/ /%20/g')?simulate=1" ;;
            *) page_url="${page_url}?simulate=1" ;;
        esac
    fi
    log "打开本地指纹测试页"
    start_env --browser "$requested" --url "$page_url"
}

doctor() {
    log "Home: $APP_HOME"
    log "OS: $(uname -s)"
    for item in chrome edge firefox; do
        if browser_exists "$item"; then
            printf '  %-8s %s\n' "$item" "OK"
        else
            printf '  %-8s %s\n' "$item" "not found"
        fi
    done
}

list_profiles() {
    if [ ! -d "$PROFILE_ROOT" ]; then
        log "暂无临时 Profile"
        return 0
    fi
    find "$PROFILE_ROOT" -maxdepth 1 -type d -name 'session-*' -print | sort
}

cleanup_profiles() {
    yes=0
    if [ "${1:-}" = "--yes" ]; then
        yes=1
    fi

    if [ ! -d "$PROFILE_ROOT" ]; then
        log "无需清理"
        return 0
    fi

    list_profiles
    if [ "$yes" -ne 1 ]; then
        printf '只会删除上面这些临时 Profile，继续请输入 YES: '
        read ans || exit 1
        [ "$ans" = "YES" ] || die "已取消"
    fi

    find "$PROFILE_ROOT" -maxdepth 1 -type d -name 'session-*' -exec rm -rf {} +
    log "清理完成"
}

case "${1:-start}" in
    start)
        shift
        start_env "$@"
        ;;
    fingerprint)
        shift
        fingerprint_test "$@"
        ;;
    doctor)
        doctor
        ;;
    list)
        list_profiles
        ;;
    cleanup)
        shift
        cleanup_profiles "$@"
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        die "未知命令: $1"
        ;;
esac
