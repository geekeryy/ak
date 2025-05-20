#!/usr/bin/env bash

# 安装go
function install() {
    if [ -z "$version" ]; then
        version=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[] | .version' | head -n 1)
        echo "[INFO] 未指定版本号，安装最新版本: $version"
    fi

    if [ -d "/usr/local/$version" ]; then
        echo "[INFO] 版本已存在，跳过安装"
        return 0
    fi

    os=$(uname | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    case $arch in
    armv6*) arch="armv6l" ;;
    armv7*) arch="arm64" ;;
    aarch64) arch="arm64" ;;
    x86) arch="386" ;;
    x86_64) arch="amd64" ;;
    i686) arch="386" ;;
    i386) arch="386" ;;
    esac

    echo "[INFO] 安装go $version"
    if [ "$HAS_CURL" = "true" ]; then
        curl -s -o "$version"."$os"-"$arch".tar.gz https://dl.google.com/go/"$version"."$os"-"$arch".tar.gz
    elif [ "$HAS_WGET" = "true" ]; then
        wget -qO "$version"."$os"-"$arch".tar.gz https://dl.google.com/go/"$version"."$os"-"$arch".tar.gz
    else
        echo "[ERROR] curl or wget is required"
        exit 1
    fi
    sudo mkdir -p /usr/local/"$version"
    sudo tar -C /usr/local/"$version" -xzf "$version"."$os"-"$arch".tar.gz
    rm "$version"."$os"-"$arch".tar.gz
    echo "[INFO] 安装成功，安装路径: /usr/local/$version/go"
    echo "[INFO] 执行: export PATH=/usr/local/$version/go/bin:\$PATH 使用当前安装版本"
}

function tags() {
    # curl -s https://go.dev/dl/?mode=json\&include=all | jq -r '.[] | .version' | grep -E "$version" | head -n 10
    get_go_versions
}

function help() {
    echo "go script."
    echo "Usage: go <command> ..."
    echo ""
    echo "Command:"
    echo "  install [version]             :安装go"
    echo "  tags:                         :获取go版本列表"
    echo "  help:                         :查看帮助"
}

version=
if [ $# = 1 ]; then
    help
else
    shift
    subcommand="$1"
    while [[ $# -gt 0 ]]; do
        case "$1" in
        install)
            if [ $# -ne 2 ]; then
                echo "[ERROR] 请指定版本号"
                exit 1
            fi
            version="$2"
            shift 2
            ;;
        *)
            shift
            ;;
        esac
    done
    "${subcommand}"
fi
