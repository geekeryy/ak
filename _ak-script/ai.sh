#!/usr/bin/env bash

function help() {
    echo "ai script."
    echo "Usage: ai <command> ..."
    echo "执行以下命令启用DeepSeek终端智能助手，使用Ctrl+G快捷键获取AI建议"
    echo ""
    echo "  echo \"source /usr/local/bin/_ak-script/ai/gen.sh\" >> ~/.bashrc"
    echo "  source ~/.bashrc"
    echo ""
    echo "Command:"
    echo "  help:                         :查看帮助"
}

if [ $# = 1 ]; then help; else "${@:2}"; fi