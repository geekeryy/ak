#!/bin/bash

source "$AK_ROOT"/lib/print.sh

function goto() {
  source cd $(docker inspect $1 | grep MergedDir | awk -F ':' '{print $2}' | cut -c 3- | rev | cut -c 3- | rev)
}

function help() {
  echo "docker script."
  echo "Usage: docker <command> ..."
  echo ""
  echo "Commands:"
  echo " goto    :进入指定容器实际存储目录"
  echo " help    :查看帮助"
}

if [ $# = 1 ]; then help; else "${@:2}"; fi