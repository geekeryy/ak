#!/usr/bin/env bash

function goto() {
  if [ -z "$1" ]; then
    help
    return 0
  fi
  path=$(docker inspect "$1" | grep MergedDir | awk -F ':' '{print $2}' | cut -c 3- | rev | cut -c 3- | rev)
  echo "$path"

  if [ "$(uname)" = "Darwin" ]; then
    docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "cd ${path} && sh"
  else
    cd "${path}" || exit 1
  fi
}

function tags() {
  # 设置默认值
  page_size=25
  page_number=1

  # 解析参数
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -n | --number)
      page_size="$2"
      shift 2
      ;;
    -p | --page)
      page_number="$2"
      shift 2
      ;;
    *)
      image_name="$1"
      shift
      ;;
    esac
  done

  if [ "$HAS_CURL" = "true" ]; then
    curl -s https://hub.docker.com/v2/repositories/library/$image_name/tags\?page_size\=$page_size\&page\=$page_number\&ordering\=last_updated\&name | jq -r ".results[] | \"$image_name:\" + .name"
  elif [ "$HAS_WGET" = "true" ]; then
    wget -qO- https://hub.docker.com/v2/repositories/library/$image_name/tags\?page_size\=$page_size\&page\=$page_number\&ordering\=last_updated\&name | jq -r ".results[] | \"$image_name:\" + .name"
  else
    echo "curl or wget is required"
  fi
}

function help() {
  echo "docker script."
  echo "Usage: docker <command> ..."
  echo ""
  echo "Commands:"
  echo "  goto    <container_name> :进入指定容器实际存储目录"
  echo "                          Darwin 需要借助特权容器使用nsenter进入"
  echo "  tags    <image_name>     :查看指定镜像名称"
  echo ""
  echo "Options:"
  echo "  -n, --number       :显示指定数量的标签[1-50 默认25]"
  echo "  -p, --page         :显示指定页码的标签[默认1]"
  echo "  help               :查看帮助"
}

if [ $# = 1 ]; then help; else "${@:2}"; fi
