#!/usr/bin/env bash

# 去除字符串两端的空格
function trim_space() {
  echo "$1" | awk '$1=$1'
}

_spinner_dot=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
_spinner_dot1=('.         ' '..        ' '...       ' '....      ' '.....     ' '......    ' '.......   ' '........  ' '......... ' '..........')
# 显示转圈
function spinners() {
  set +u
  local spinner_array_name=$1
  eval "local spinner_array=(\"\${${spinner_array_name}[@]}\")"
  for char in "${spinner_array[@]}"; do
    # 使用 ANSI 转义码：
    # \r 回车（覆盖当前行）
    # \e[32m 设置绿色字体
    # \e[0m 重置样式
    printf "\r\e[32m %s $2\e[0m" "$char"
    sleep 0.1 # 调整速度（秒）
  done
}

# 等待条件成立,否则显示转圈
function wait_for_condition() {
  msg=$1
  shift
  while ! ${@} &>/dev/null; do
    spinners _spinner_dot "$msg"
  done
  echo ""
}

# 安装sqlite
# 需要gcc
function sqlite_install() {
  version="3490200"
  if [ $HAS_CURL ]; then
    curl -s -o sqlite-autoconf-${version}.tar.gz https://www.sqlite.org/2025/sqlite-autoconf-${version}.tar.gz
  elif [ $HAS_WGET ]; then
    wget -qO sqlite-autoconf-${version}.tar.gz https://www.sqlite.org/2025/sqlite-autoconf-${version}.tar.gz
  else
    echo "curl or wget is required"
    return 1
  fi
  tar xvzf sqlite-autoconf-${version}.tar.gz
  cd sqlite-autoconf-${version} || exit 1
  ./configure --prefix=/usr/local
  make
  sudo make install
  sudo rm -rf sqlite-autoconf-${version}.tar.gz sqlite-autoconf-${version}
  echo "sqlite installed"
}

# 启动docker
function start_docker() {
  if ! type docker &>/dev/null; then
    echo "docker is not installed"
    return 1
  fi

  if ! docker info &>/dev/null; then
    echo "Docker is not running"
    if [ "$(uname)" = "Darwin" ]; then
      open -a Docker
      wait_for_condition "Opening Docker..." docker info
    else
      systemctl start docker
    fi
  fi
}

# 获取go版本列表
# 缓存key：go_versions
function get_go_versions() {
  content=$(get_cache "go_versions")
  if [ -z "$content" ]; then
    if [ $HAS_CURL ]; then
      content=$(curl -s "https://go.dev/dl/?mode=json&include=all")
    elif [ $HAS_WGET ]; then
      content=$(wget -qO- "https://go.dev/dl/?mode=json&include=all")
    else
      echo "curl or wget is required"
      return 1
    fi
    set_cache "go_versions" "$content"
  fi

  # Deepseek Coding
  echo "$content" | jq -r '
  # 定义函数解析版本号
  def parse_version:
    . as $v | ltrimstr("go") | split(".") |
    if length >=3 and (.[0] | test("^[0-9]+$")) and (.[1] | test("^[0-9]+$")) and (.[2] | test("^[0-9]+$")) then
      { major: (.[0] + "." + .[1]), patch: (.[2] | tonumber), version: $v }
    else
      null
    end;

  # 处理数据
  [.[].version | select(test("^go[0-9]+\\.[0-9]+\\.[0-9]+$")) | parse_version | select(. != null)] |
  group_by(.major) |  # 按主版本分组
  map({
    major: .[0].major,
    versions: (sort_by(-.patch) | map(.version)[0:2])  # 每个主版本取最新两个小版本
  }) |
  sort_by(.major | split(".") | map(tonumber)) | reverse |  # 主版本降序排列
  .[0:5] |  # 取前5个主版本
  .[].versions[]  # 输出所有版本
'
}
