#!/usr/bin/env bash

set -eu

: "${DEBUG:="$(env | grep -q DEBUG && echo true || echo false)"}"
: "${HAS_CURL:="$(type "curl" &>/dev/null && echo true || echo false)"}"
: "${HAS_WGET:="$(type "wget" &>/dev/null && echo true || echo false)"}"
: "${HAS_GIT:="$(type "git" &>/dev/null && echo true || echo false)"}"
: "${HAS_TAR:="$(type "tar" &>/dev/null && echo true || echo false)"}"

# Set debug if desired
if [ "${DEBUG}" == "true" ]; then
    set -x
fi

AK_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AK_SUBSCRIPT_DIR="$AK_ROOT"/_ak-script

# shellcheck source=/dev/null
source "$AK_SUBSCRIPT_DIR"/lib/*.sh

function version() {
    head -1 "$AK_SUBSCRIPT_DIR"/VERSION
}

function help() {
    echo "AK devops script collection."
    echo "Environment:"
    echo "  DEBUG: 环境变量DEBUG=true表示开启调试模式"
    echo ""
    echo "Usage: ak <command|script> ..."
    echo "Commands:"
    echo "  help                          :查看帮助"
    echo "  version                       :查看版本"
    echo "  update [tag|branch]           :更新版本"
    echo "                                使用 \"ak update\" 安装最新稳定版本; 使用 \"ak update [tag|branch]\" 安装指定版本"
    echo "Scripts:"
    echo "  example:       这是一个示例脚本,ak example hello 试试！"
    echo "  docker:        容器相关的脚本工具"
    echo "  ssl:           证书相关的脚本工具"
}

function update() {
    shift
    "$AK_SUBSCRIPT_DIR"/install.sh "${@}"
}

if [ $# = 0 ]; then
    help
else
    case $1 in
    "help")
        help
        ;;
    "version")
        version
        ;;
    "update")
        update "${@}"
        ;;
    *)
        # shellcheck source=/dev/null
        source "$AK_SUBSCRIPT_DIR"/"$1".sh "${@}"
        ;;
    esac
fi
