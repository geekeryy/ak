#!/usr/bin/env bash

set -eu

trap 'onCtrlC' INT
function onCtrlC() {
    exit 1
}

: "${DEBUG:="$(env | grep -q AK_DEBUG && echo true || echo false)"}"

# Set debug if desired
if [ "${DEBUG}" = "true" ]; then
    set -x
fi

# 依赖检查
check_dependencies() {
    # 检查并安装 jq
    if ! command -v jq &>/dev/null; then
        echo "[INFO] 未找到jq工具，正在安装..."

        # 检测操作系统
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux系统

            # 检查当前用户是否有sudo权限
            local sudo_prefix=""
            if [ "$EUID" -ne 0 ]; then
                if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
                    sudo_prefix="sudo "
                elif [ "$EUID" -ne 0 ]; then
                    echo "[WARN] 当前用户不是root且无sudo权限，可能需要手动安装jq"
                    sudo_prefix="sudo "
                fi
            fi

            # 安装jq
            if command -v apt-get &>/dev/null; then
                # Debian/Ubuntu
                echo "[INFO] 检测到Debian/Ubuntu系统，使用apt安装jq"
                $sudo_prefix apt-get update && $sudo_prefix apt-get install -y jq
            elif command -v yum &>/dev/null; then
                # CentOS/RHEL
                echo "[INFO] 检测到CentOS/RHEL系统，使用yum安装jq"
                $sudo_prefix yum install -y jq
            elif command -v dnf &>/dev/null; then
                # Fedora
                echo "[INFO] 检测到Fedora系统，使用dnf安装jq"
                $sudo_prefix dnf install -y jq
            elif command -v apk &>/dev/null; then
                # Alpine
                echo "[INFO] 检测到Alpine系统，使用apk安装jq"
                $sudo_prefix apk add jq
            else
                echo "[ERROR] 无法识别Linux发行版，请手动安装jq"
                return 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &>/dev/null; then
                echo "[INFO] 检测到macOS系统，使用brew安装jq"
                brew install jq
            else
                echo "[ERROR] 需要安装Homebrew才能自动安装jq"
                echo "请访问 https://brew.sh/ 安装Homebrew，或手动安装jq"
                return 1
            fi
        else
            echo "[ERROR] 不支持的操作系统: $OSTYPE"
            echo "请手动安装jq工具"
            return 1
        fi

        # 再次检查是否安装成功
        if ! command -v jq &>/dev/null; then
            echo "[ERROR] jq安装失败，请手动安装"
            return 1
        else
            echo "[INFO] jq安装成功"
        fi
    fi
}

check_dependencies

AK_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AK_SUBSCRIPT_DIR="$AK_ROOT"/_ak-script

# shellcheck source=/dev/null
source "$AK_SUBSCRIPT_DIR"/lib/check.sh
# shellcheck source=/dev/null
source "$AK_SUBSCRIPT_DIR"/lib/print.sh
# shellcheck source=/dev/null
source "$AK_SUBSCRIPT_DIR"/lib/cache.sh
# shellcheck source=/dev/null
source "$AK_SUBSCRIPT_DIR"/lib/util.sh

function version() {
    head -1 "$AK_SUBSCRIPT_DIR"/VERSION
}

function help() {
    echo "AK devops script collection."
    echo "Environment:"
    echo "  DEEPSEEK_API_KEY: 用于DeepSeek终端智能助手"
    echo "Usage: ak <command|script> ..."
    echo "Commands:"
    echo "  help                          :查看帮助"
    echo "  version                       :查看版本"
    echo "  update [tag|branch]           :更新版本"
    echo "                                 使用 \"ak update\" 安装最新稳定版本; 使用 \"ak update [tag|branch]\" 安装指定版本或分支"
    echo "Scripts:"
    echo "  example                       :这是一个示例脚本,ak example hello 试试！"
    echo "  docker                        :容器相关的脚本工具"
    echo "  ssl                           :证书相关的脚本工具"
    echo "  go                            :go语言相关的脚本工具"
    echo "  ai                            :DeepSeek终端智能助手"
    echo "  ps                            :进程信息查看工具"
    echo ""
    echo "Options:"
    echo "  --debug:                      :开启调试模式"
}

function update() {
    shift
    if [ $# -eq 0 ]; then
        # shellcheck source=/dev/null
        source "$AK_SUBSCRIPT_DIR"/install.sh
    else
        # shellcheck source=/dev/null
        source "$AK_SUBSCRIPT_DIR"/install.sh --version "${@}"
    fi
}

if [ $# = 0 ]; then
    help
else
    # 如果存在--debug参数，则开启调试模式，并从参数列表中移除该参数
    new_args=()
    for arg in "$@"; do
        if [[ "$arg" != "--debug" ]]; then
            new_args+=("$arg") # 保留非 --debug 的参数
        else
            set -x
        fi
    done
    set -- "${new_args[@]}"

    case $1 in
    "help")
        help
        ;;
    "version")
        version
        ;;
    "update")
        update "${@}"
        exit 0
        ;;
    *)
        if [ -f "$AK_SUBSCRIPT_DIR"/"$1".sh ]; then
            # shellcheck source=/dev/null
            source "$AK_SUBSCRIPT_DIR"/"$1".sh "${@}"
        else
            echo "Script $1 not found"
            help
        fi
        ;;
    esac
fi
