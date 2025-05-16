#!/usr/bin/env bash

: ${BINARY_NAME:="ak"}
: ${USE_SUDO:="true"}
: ${DEBUG:="false"}
: ${AK_INSTALL_DIR:="/usr/local/bin"}
: ${GH_TOKEN:="Z2l0aHViX3BhdF8xMUFDN0pKRVkwYUpaNGJnU3lacmRGX2pxem9CTm9ORXNiRTVrUW83RVd4ZWY5eVQ2emZYNjFuM3draE92OUt4a2tTR0RJNTNKRTVuamxXM01v"}


HAS_CURL="$(type "curl" &>/dev/null && echo true || echo false)"
HAS_WGET="$(type "wget" &>/dev/null && echo true || echo false)"
HAS_GIT="$(type "git" &>/dev/null && echo true || echo false)"
HAS_TAR="$(type "tar" &>/dev/null && echo true || echo false)"

# initArch discovers the architecture for this system.
initArch() {
    ARCH=$(uname -m)
    case $ARCH in
    armv5*) ARCH="armv5" ;;
    armv6*) ARCH="armv6" ;;
    armv7*) ARCH="arm" ;;
    aarch64) ARCH="arm64" ;;
    x86) ARCH="386" ;;
    x86_64) ARCH="amd64" ;;
    i686) ARCH="386" ;;
    i386) ARCH="386" ;;
    esac
}

# initOS discovers the operating system for this system.
initOS() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')

    case "$OS" in
    # Minimalist GNU for Windows
    mingw* | cygwin*) OS='windows' ;;
    esac
}

# runs the given command as root (detects if we are root already)
runAsRoot() {
    if [ $EUID -ne 0 -a "$USE_SUDO" = "true" ]; then
        sudo "${@}"
    else
        "${@}"
    fi
}

# verifySupported checks that the os/arch combination is supported for
# binary builds, as well whether or not necessary tools are present.
verifySupported() {
    local supported="darwin-amd64\ndarwin-arm64\nlinux-386\nlinux-amd64\nlinux-arm\nlinux-arm64\nlinux-ppc64le\nlinux-s390x\nlinux-riscv64\nwindows-amd64\nwindows-arm64"
    if ! echo "${supported}" | grep -q "${OS}-${ARCH}"; then
        echo "No prebuilt binary for ${OS}-${ARCH}."
        echo "To build from source, go to https://github.com/geekeryy/ak"
        exit 1
    fi

    if [ "${HAS_CURL}" != "true" ] && [ "${HAS_WGET}" != "true" ]; then
        echo "Either curl or wget is required"
        exit 1
    fi

    if [ "${HAS_GIT}" != "true" ]; then
        echo "[WARNING] Could not find git. It is required for plugin installation."
    fi

    if [ "${HAS_TAR}" != "true" ]; then
        echo "[ERROR] Could not find tar. It is required to extract the AK binary archive."
        exit 1
    fi
}

# checkDesiredVersion checks if the desired version is available.
checkDesiredVersion() {
    if [ "x$DESIRED_VERSION" == "x" ]; then
        # Get tag from release URL
        local latest_release_url="https://api.github.com/repos/geekeryy/ak/releases/latest"
        local latest_release_response=""
        if [ "${HAS_CURL}" == "true" ]; then
            # TODO 使用api封装一下
            token=$(echo $GH_TOKEN | base64)
            latest_release_response=$(curl --header "Authorization: Bearer $token" -L --silent --show-error --fail "$latest_release_url" 2>&1 || true)
        elif [ "${HAS_WGET}" == "true" ]; then
            latest_release_response=$(wget --header "Authorization: Bearer $token" -L --silent --show-error --fail "$latest_release_url" -q -O - 2>&1 || true)
        fi
        TAG=$(echo "$latest_release_response" | jq .tag_name | tr -d '"')
        if [ "x$TAG" == "x" ]; then
            printf "Could not retrieve the latest release tag information from %s: %s\n" "${latest_release_url}" "${latest_release_response}"
            exit 1
        fi
    else
        TAG=$DESIRED_VERSION
    fi
}

# checkAKInstalledVersion checks which version of AK is installed and
# if it needs to be changed.
checkAKInstalledVersion() {
    if [[ -f "${AK_INSTALL_DIR}/${BINARY_NAME}" ]]; then
        local version=$("${AK_INSTALL_DIR}/${BINARY_NAME}" version)
        if [[ "$version" == "$TAG" ]]; then
            echo "AK ${version} is already ${DESIRED_VERSION:-latest}"
            return 0
        else
            echo "AK ${TAG} is available. Changing from version ${version}."
            return 1
        fi
    else
        return 1
    fi
}

# downloadFile downloads the latest binary package and also the checksum
# for that binary.
downloadFile() {
    AK_DIST="$TAG.tar.gz"
    DOWNLOAD_URL="https://github.com/geekeryy/ak/archive/refs/$DOWNLOAD_TYPE/$AK_DIST"
    AK_TMP_ROOT="$(mktemp -dt ak-installer)"
    AK_TMP_FILE="$AK_TMP_ROOT/$AK_DIST"
    echo "Downloading $DOWNLOAD_URL"
    if [ "${HAS_CURL}" == "true" ]; then
        curl -SsL "$DOWNLOAD_URL" -o "$AK_TMP_FILE"
    elif [ "${HAS_WGET}" == "true" ]; then
        wget -q -O "$AK_TMP_FILE" "$DOWNLOAD_URL"
    fi
}

# installFile installs the AK binary.
installFile() {
    AK_TMP="$AK_TMP_ROOT/$BINARY_NAME"
    mkdir -p "$AK_TMP"
    tar xf "$AK_TMP_FILE" -C "$AK_TMP"
    echo "Preparing to install $BINARY_NAME into ${AK_INSTALL_DIR}"
    \cp "$AK_TMP/$BINARY_NAME-${TAG#v}/ak.bash" "$AK_INSTALL_DIR/$BINARY_NAME"
    \cp -r "$AK_TMP/$BINARY_NAME-${TAG#v}/_ak-script" "$AK_INSTALL_DIR/"
    echo "$BINARY_NAME installed into $AK_INSTALL_DIR/$BINARY_NAME"
}

# fail_trap is executed if an error occurs.
fail_trap() {
    result=$?
    if [ "$result" != "0" ]; then
        if [[ -n "$INPUT_ARGUMENTS" ]]; then
            echo "Failed to install $BINARY_NAME with the arguments provided: $INPUT_ARGUMENTS"
            help
        else
            echo "Failed to install $BINARY_NAME"
        fi
        echo -e "\tFor support, go to https://github.com/geekeryy/ak."
    fi
    cleanup
    exit $result
}

# testVersion tests the installed client to make sure it is working.
testVersion() {
    set +e
    AK="$(command -v $BINARY_NAME)"
    if [ "$?" = "1" ]; then
        echo "$BINARY_NAME not found. Is $AK_INSTALL_DIR on your "'$PATH?'
        exit 1
    fi
    set -e
}

# help provides possible cli installation arguments
help() {
    echo "Accepted cli arguments are:"
    echo -e "\t[--help|-h ] ->> prints this help"
    echo -e "\t[--version|-v <desired_version>] . When not defined it fetches the latest release tag from the github"
    echo -e "\te.g. --version v3.0.0 or -v main"
}

cleanup() {
    if [[ -d "${AK_TMP_ROOT:-}" ]]; then
        rm -rf "$AK_TMP_ROOT"
    fi
}

# Execution

#Stop execution on any error
trap "fail_trap" EXIT
set -e

# Set debug if desired
if [ "${DEBUG}" == "true" ]; then
    set -x
fi

# Parsing input arguments (if any)
export INPUT_ARGUMENTS="${@}"
DOWNLOAD_TYPE="tags"
set -u
while [[ $# -gt 0 ]]; do
    case $1 in
    '--version' | -v)
        shift
        if [[ $# -ne 0 ]]; then
            export DESIRED_VERSION="${1}"
            if [[ "$1" != "v"* ]]; then
                export DOWNLOAD_TYPE="heads"
            fi
        else
            echo -e "Please provide the desired version. e.g. --version v3.0.0 or -v main"
            exit 0
        fi
        ;;
    '--help' | -h)
        help
        exit 0
        ;;
    *)
        exit 1
        ;;
    esac
    shift
done
set +u

initArch
initOS
verifySupported
checkDesiredVersion
if ! checkAKInstalledVersion; then
    downloadFile
    installFile
fi
testVersion
cleanup
