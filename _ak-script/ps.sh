#!/usr/bin/env bash

# find /proc -maxdepth 1 -type d -name '[0-9]*' | xargs -I{} sh -c 'echo {}; ls -1 "{}/fd" 2>/dev/null | wc -l' | paste - - | sort -k2 -nr | head -20
# for pid in /proc/[0-9]*; do pid=${pid##*/}; count=$(ls -1 /proc/$pid/fd 2>/dev/null | wc -l); comm=$(cat /proc/$pid/comm 2>/dev/null); [ -n "$count" ] && printf "%-8s %-6s %s\n" "$count" "$pid" "$comm"; done | sort -rn | head -20

function fdcount() {
    printf "%-10s %-6s %s\n"   "comm" "pid" "count"  
    if [ "$(uname)" = "Darwin" ]; then
        lsof -n 2>/dev/null | 
            awk 'NR>1 { 
                count[$2]++; 
                name[$2]=$1 
            } END { 
                for (pid in count) 
                    printf "%-10s %-6s %d\n", name[pid] , pid, count[pid]
            }' | LC_ALL=C sort -k1,1 -rn | head -20
    else
        for pid in /proc/[0-9]*; do pid=${pid##*/}; count=$(ls -1 /proc/$pid/fd 2>/dev/null | wc -l); comm=$(cat /proc/$pid/comm 2>/dev/null); [ -n "$count" ] && printf "%-10s %-6s %s \n" "$comm" "$pid" "$count" ; done | sort -rn | head -20
    fi
}

_get_fd_count() {
  local pid=$1
  [ -d "/proc/$pid" ] && \
  find "/proc/$pid/fd" -maxdepth 1 -type l 2>/dev/null | wc -l
}

_calculate_tree_fd() {
    local pid=$1
    local total_fd=0
    
    # 统计当前进程的FD
    if [ -d "/proc/$pid/fd" ]; then
        current_fd=$(ls -1 "/proc/$pid/fd" 2>/dev/null | wc -l)
        total_fd=$((total_fd + current_fd))
    fi
    
    # 递归统计所有子进程
    for child in $(pgrep -P $pid); do
        total_fd=$((total_fd + $(calculate_tree_fd $child)))
    done
    
    echo $total_fd
}

function help() {
    echo "example script."
    echo "Usage: ps <command> ..."
    echo ""
    echo "Commands:"
    echo "  fdcount         :查看进程打开的文件描述符数量"
    echo "  help            :查看帮助"
}

if [ $# = 1 ]; then help; else "${@:2}"; fi
