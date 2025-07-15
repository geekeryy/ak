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
    if ! command -v jq &>/dev/null; then
        echo "[ERROR] 需要安装jq工具"
        echo "Ubuntu: sudo apt install jq"
        echo "CentOS: sudo yum install jq"
        echo "Mac:    brew install jq"
        return 1
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
    echo "                                 使用 \"ak update\" 安装最新稳定版本; 使用 \"ak update [tag|branch]\" 安装指定版本"
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
