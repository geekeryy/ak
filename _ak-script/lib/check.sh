#!/usr/bin/env bash

: "${HAS_CURL:="$(type "curl" &>/dev/null && echo true || echo false)"}"
: "${HAS_WGET:="$(type "wget" &>/dev/null && echo true || echo false)"}"
: "${HAS_GIT:="$(type "git" &>/dev/null && echo true || echo false)"}"
: "${HAS_TAR:="$(type "tar" &>/dev/null && echo true || echo false)"}"