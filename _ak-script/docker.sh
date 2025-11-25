#!/usr/bin/env bash

function goto() {
	start_docker
	path=$(docker inspect "$1" | grep MergedDir | awk -F ':' '{print $2}' | cut -c 3- | rev | cut -c 3- | rev)
	echo "[INFO] MergedDir: $path"

	if [ "$(uname)" = "Darwin" ]; then
		# 如果没有找到容器，则进入MacOS的Docker虚拟机根目录
		docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh -c "cd ${path} && sh"
	else
		cd "${path}" || exit 1
	fi
}

function tags() {
	# 设置默认值
	page_size=25
	page_number=1
	image_name=""
	keyword=""
	library="library/"
	# 解析参数
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-n | --number)
			page_number=$(($2 / $page_size + 1))
			shift 2
			;;
		-k | --keyword)
			keyword="$2"
			shift 2
			;;
		*)
			image_name="$1"
			if [[ "$image_name" =~ "/" ]]; then
				library=""
			fi
			shift
			;;
		esac
	done

	if [ -z "$image_name" ]; then
		echo "[ERROR] image_name is required"
		help
		exit 1
	fi

	for i in $(seq 1 "$page_number"); do
		result=$(_query_url "$i")
		if [ $? -ne 0 ]; then
			exit 0
		fi
		tag_lines=$(echo "$result" | jq -r ".results[] | \"${image_name}:\" + .name")
		if [ -n "$keyword" ]; then
			echo "$tag_lines" | grep --color=auto "$keyword" || true
		else
			echo "$tag_lines"
		fi
	done
}

_query_url() {
	base_url="https://hub.docker.com/v2/repositories/${library}${image_name}/tags"
	local page=$1
	local url="${base_url}?page_size=${page_size}&page=${page}&ordering=last_updated&name"
	if [ "$HAS_CURL" = "true" ]; then
		curl -s "$url" || true
	elif [ "$HAS_WGET" = "true" ]; then
		wget -qO- "$url" || true
	else
		echo "[ERROR] curl or wget is required"
		return 1
	fi
}

function help() {
	echo "docker script."
	echo "Usage: docker <command> ..."
	echo ""
	echo "Commands:"
	echo "  help                     :查看帮助"
	echo "  goto   <container_name>  :进入指定容器实际存储目录"
	echo "                            如果Docker未启动会自动启动"
	echo "                            Darwin 需要借助特权容器使用nsenter进入"
	echo "                            Linux 使用source ak docker goto <container_name> 直接进入"
	echo "  tags   <image_name>      :查看指定镜像名称"
	echo "             -n, --number  :显示指定数量的标签[1- 默认25]"
	echo "             -k, --keyword :搜索关键词"
}

if [ $# = 1 ]; then help; else "${@:2}"; fi
