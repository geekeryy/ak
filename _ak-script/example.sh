#!/usr/bin/env bash

function hello() {
    echo "hello $*"
}

function help() {
    echo "example script."
    echo "Usage: example <command> ..."
    echo ""
    echo "Commands:"
    echo "  hello    <name> :打印指定名称"
    echo "  help            :查看帮助"
}

if [ $# = 1 ]; then help; else "${@:2}"; fi
