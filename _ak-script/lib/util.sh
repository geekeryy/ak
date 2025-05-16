#!/usr/bin/env bash

# 去除字符串两端的空格
function trim_space() {
  echo "$1" | awk '$1=$1'
}
