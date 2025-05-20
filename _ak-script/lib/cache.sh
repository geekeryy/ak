#!/usr/bin/env bash

# 缓存目录
cache_dir="$HOME/.cache/ak"
cache_max_age=3600 # 缓存最大有效期，单位：秒

if [ ! -d "$cache_dir" ]; then
    mkdir -p "$cache_dir"
fi

# 函数：获取文件修改时间（兼容macOS和Linux）
function get_file_mtime() {
    if [ "$(uname)" = "Darwin" ]; then
        # macOS: 使用stat -f %m
        stat -f %m "$1" 2>/dev/null || echo 0
    else
        # Linux: 使用stat -c %Y
        stat -c %Y "$1" 2>/dev/null || echo 0
    fi
}

function get_cache() {
    # 检查缓存有效性
    current_time=$(date +%s)
    file_mtime=$(get_file_mtime "$cache_dir/$1.cache")
    file_age=$((current_time - file_mtime))

    if [ -f "$cache_dir/$1.cache" ] && [ $file_age -le $cache_max_age ]; then
        cat "$cache_dir/$1.cache"
    fi
}

# 函数：设置缓存
function set_cache() {
    echo "$2" >"$cache_dir/$1.cache"
}
