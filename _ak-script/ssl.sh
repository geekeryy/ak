#!/usr/bin/env bash

# prompt 是否允许交互式输入主题信息，否则需使用-subj设置主题信息
# subjectAltName 允许证书绑定多个域名、IP ,现代浏览器要求 HTTPS 证书必须包含 subjectAltName（即使 CommonName 已设置）
# basicConstraints 标识证书是否为 CA 证书（可签发其他证书）
# keyUsage 指定证书的用途，包括数字签名digitalSignature、密钥加密keyEncipherment、允许此证书签发其他证书keyCertSign、吊销列表cRLSign等
# extendedKeyUsage 进一步细化证书用途,serverAuth 服务器认证,clientAuth 客户端认证

function ca() {
  subj=""

  if [ -n "$common_name" ]; then
    subj="-subj /CN=$common_name"
  fi

  if [ -f "$output"/ca.key ]; then
    echo "CA私钥已存在，跳过生成"
  else
    # 生成CA私钥
    echo "生成CA私钥" "$output"/ca.key
    openssl genrsa -out "$output"/ca.key 4096
  fi

  if [ -f "$output"/ca.crt ]; then
    echo "CA证书已存在，跳过生成"
  else
    # 生成自签名CA证书（关键：显式定义CA扩展属性）
    echo "生成CA证书" "$output"/ca.crt
    eval openssl req -x509 -new -nodes -key "$output"/ca.key -sha256 "$subj" -days "$days" -extensions v3_ca -out "$output"/ca.crt \
      -config <(
        cat <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = yes

[req_distinguished_name]
CN = AKRootCA

[v3_ca]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF
      )
  fi
}

function client() {
  subj=""
  name="client"

  if [ ! -f "$ca_path"/ca.key ] || [ ! -f "$ca_path"/ca.crt ]; then
    echo "[ERROR] CA私钥或证书不存在"
    exit 1
  fi

  if [ -n "$common_name" ]; then
    subj="-subj \"/CN=$common_name\""
    name="$common_name"
  fi

  if [ -f "$output"/"$name".key ]; then
    echo "[INFO] 客户端私钥已存在，跳过生成"
  else
    # 生成客户端私钥
    echo "[INFO] 生成客户端私钥" "$output"/"$name".key
    openssl genrsa -out "$output"/"$name".key 4096
  fi

  if [ -f "$output"/"$name".csr ]; then
    echo "[INFO] 客户端证书请求已存在，跳过生成"
  else
    # 创建CSR
    echo "[INFO] 生成客户端证书请求" "$output"/"$name".csr
    eval openssl req -new -key "$output"/"$name".key "$subj" -out "$output"/"$name".csr
  fi

  # 用CA签发客户端证书
  echo "[INFO] 签发客户端证书" "$output"/"$name".crt
  openssl x509 -req -in "$output"/"$name".csr -CA "$ca_path"/ca.crt -CAkey "$ca_path"/ca.key -CAcreateserial -days "$days" -sha256 \
    -extfile <(printf "basicConstraints=critical,CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=clientAuth") \
    -out "$output"/"$name".crt
}

function server() {
  subj=""
  name="server"
  if [ -n "$common_name" ]; then
    subj="-subj \"/CN=$common_name\""
    name="$common_name"
    if [ -z "$san" ]; then
      san="DNS:$common_name"
    fi
  fi

  if [ ! -f "$ca_path"/ca.key ] || [ ! -f "$ca_path"/ca.crt ]; then
    echo "[ERROR] CA私钥或证书不存在"
    exit 1
  fi

  if [ -z "$san" ]; then
    echo "[ERROR] 请设置SAN，例如: -san \"DNS:www.example.com,DNS:example.com,IP:192.168.1.1\""
    exit 1
  fi

  if [ -f "$output"/"$name".key ]; then
    echo "[INFO] 服务器私钥已存在，跳过生成"
  else
    # 生成服务器私钥
    echo "[INFO] 生成服务器私钥" "$output"/"$name".key
    openssl genrsa -out "$output"/"$name".key 4096
  fi

  if [ -f "$output"/"$name".csr ]; then
    echo "[INFO] 服务器证书请求已存在，跳过生成"
  else
    # 创建证书签名请求(CSR)
    echo "[INFO] 生成服务器证书请求" "$output"/"$name".csr
    eval openssl req -new -key "$output"/"$name".key "$subj" -out "$output"/"$name".csr
  fi

  if [ -f "$output"/"$name".crt ]; then
    echo "[INFO] 服务器证书已存在，跳过生成"
  else
    # 用CA签发证书（注意-extfile设置）
    echo "[INFO] 签发服务器证书" "$output"/"$name".crt
    openssl x509 -req -in "$output"/"$name".csr -CA "$ca_path"/ca.crt -CAkey "$ca_path"/ca.key -CAcreateserial -days "$days" -sha256 \
      -extfile <(printf "subjectAltName=%s\nbasicConstraints=critical,CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth" "$san") \
      -out "$output"/"$name".crt
  fi
}

function check() {
  checkfile=""
  if [ -z "$checkfile" ]; then
    echo "[ERROR] 请输入检查文件"
    exit 1
  fi
  echo "[INFO] 检查证书信息"
  openssl x509 -in "$checkfile" -text -noout

  if [ -n "$ca_path" ]; then
    echo "[INFO] 检查证书是否由CA签发"
    openssl verify -CAfile "$ca_path"/ca.crt "$checkfile"
  fi
}

function help() {
  echo "ssl script."
  echo "Usage: ssl <command> ..."
  echo ""
  echo "Example:"
  echo "  ak ssl ca                                                                  :在当前目录创建CA证书"
  echo "  ak ssl client                                                              :使用当前目录CA创建客户端证书，当服务器需要使用客户端证书验证时使用"
  echo "  ak ssl server -cn www.example.com -san DNS:www.example.com,IP:192.168.1.1  :使用当前目录CA创建服务器证书"
  echo "  ak ssl check -f ca.crt                                                     :检查证书信息"
  echo "  ak ssl check -f ca.crt -ca /path/to/ca.crt                                 :检查证书是否由CA签发"
  echo ""
  echo "Commands:"
  echo "  ca                                :生成CA证书"
  echo "  client                            :生成客户端证书"
  echo "  server [-san <DNS:,IP:>]          :生成服务器证书"
  echo "                                     设置SAN，例如: -san \"DNS:www.example.com,DNS:example.com,IP:192.168.1.1\""
  echo "  check [-f <file>]                 :检查证书信息"
  echo "  help                              :查看帮助"
  echo ""
  echo "Options:"
  echo "  -cn, --common-name       :设置通用名称"
  echo "  -d, --days               :设置有效期 默认365天"
  echo "  -o, --output             :设置输出文件路径 默认当前目录"
  echo "  -ca, --ca-path           :设置CA证书文件路径 默认当前目录"
}

output=.
ca_path=.
days=365
common_name=
san=
checkfile=
if [ $# = 1 ]; then
  help
else
  shift
  subcommand="$1"
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      help
      exit 0
      ;;
    -cn | --common-name)
      common_name="$2"
      shift 2
      ;;
    -d | --days)
      days="$2"
      shift 2
      ;;
    -ca | --ca-path)
      ca_path="$2"
      shift 2
      ;;
    -o | --output)
      output="$2"
      shift 2
      ;;
    -san)
      san="$2"
      shift 2
      ;;
    -f)
      checkfile="$2"
      shift 2
      ;;
    *)
      shift
      ;;
    esac
  done
  if [ ! -d "$output" ]; then
    echo "[INFO] 输出目录不存在，创建输出目录" "$output"
    mkdir -p "$output"
  fi
  "${subcommand}"
fi
