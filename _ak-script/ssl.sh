#!/usr/bin/env bash

function _param_parse() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -cn | --common-name)
      common_name="$2"
      shift 2
      ;;
    -d | --days)
      days="$2"
      shift 2
      ;;
    -ca | --ca-file)
      ca_path="$2"
      shift 2
      ;;
    -o | --output)
      output="$2"
      if [ ! -d "$output" ]; then
        mkdir -p "$output"
      fi
      shift 2
      ;;
    *)
      help
      exit 1
      ;;
    esac
  done
}

function ca() {
  _param_parse "$@"
  if [ -z "$common_name" ]; then
    echo "请设置通用名称"
    exit 1
  fi

  # 生成CA私钥
  openssl genrsa -out "$output"/ca.key 2048

  # 生成自签名CA证书（关键：显式定义CA扩展属性）
  openssl req -x509 -new -nodes -key "$output"/ca.key -sha256 -days "$days" \
    -subj "/CN=$common_name" \
    -extensions v3_ca \
    -out "$output"/ca.crt \
    -config <(
      cat <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no

[req_distinguished_name]
CN = MyRootCA

[v3_ca]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF
    )

}

function client() {
  _param_parse "$@"
  if [ -z "$common_name" ]; then
    echo "请设置通用名称"
    exit 1
  fi

  # 生成客户端私钥
  openssl genrsa -out "$output"/client.key 2048

  # 创建CSR
  openssl req -new -key "$output"/client.key -subj "/CN=$common_name" -out "$output"/client.csr

  # 用CA签发客户端证书
  openssl x509 -req -in "$output"/client.csr -CA "$ca_path"/ca.crt -CAkey "$ca_path"/ca.key -CAcreateserial \
    -days 365 -sha256 \
    -extfile <(printf "basicConstraints=critical,CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=clientAuth") \
    -out "$output"/client.crt
}

function server() {
  _param_parse "$@"
  if [ -z "$common_name" ]; then
    echo "请设置通用名称"
    exit 1
  fi

  # 生成服务器私钥
  openssl genrsa -out "$output"/server.key 2048

  # 创建证书签名请求(CSR)
  openssl req -new -key "$output"/server.key -subj "/CN=$common_name" -out "$output"/server.csr

  # 用CA签发证书（注意-extfile设置）
  openssl x509 -req -in "$output"/server.csr -CA "$ca_path"/ca.crt -CAkey "$ca_path"/ca.key -CAcreateserial \
    -days 365 -sha256 \
    -extfile <(printf "subjectAltName=DNS:%s\nbasicConstraints=critical,CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth" "$common_name") \
    -out "$output"/server.crt
}

function check() {
  _param_parse "$@"
  openssl x509 -in "$ca_path"/ca.crt -text -noout | grep -A1 "Basic Constraints"
}

function help() {
  echo "ssl script."
  echo "Usage: ssl <command> ..."
  echo ""
  echo "Commands:"
  echo "  ca          :生成CA证书"
  echo "  client      :生成客户端证书"
  echo "  server      :生成服务器证书"
  echo "  check       :检查证书"
  echo "  help        :查看帮助"
  echo ""
  echo "Options:"
  echo "  -cn, --common-name :设置通用名称"
  echo "  -d, --days         :设置有效期"
  echo "  -ca, --ca-file     :设置CA证书文件路径"
  echo "  -o, --output       :设置输出文件路径"
}

output=.
ca_path=.
days=365
common_name=
if [ $# = 1 ]; then
  help
else
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -cn | --common-name)
      common_name="$2"
      shift 2
      ;;
    -d | --days)
      days="$2"
      shift 2
      ;;
    -ca | --ca-file)
      ca_path="$2"
      shift 2
      ;;
    -o | --output)
      output="$2"
      shift 2
      ;;
    *)
      "${@}"
      shift
      ;;
    esac
  done
fi
