source /usr/local/bin/_ak-script/lib/util.sh

function _docker-completion() {
    case ${COMP_WORDS[$((COMP_CWORD - 1))]} in
    "goto")
    
        if ! docker info &>/dev/null ; then
            if [ "$(uname)" = "Darwin" ]; then
                open -a Docker
            else
               systemctl start docker
            fi
            COMPREPLY=('Docker' 'is' 'opening' '...')
            return 0
        fi

        COMPREPLY=()
        if [[ -n ${COMP_WORDS[$((COMP_CWORD))]} ]]; then
            while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$(docker ps --format "{{.Names}}" | grep "${COMP_WORDS[$((COMP_CWORD))]}")")
        else
            while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$(docker ps --format "{{.Names}}")" "${COMP_WORDS[$((COMP_CWORD))]}")
        fi
        ;;
    esac
}

function _ak_completions() {
    AK_SUBSCRIPT_DIR="$(dirname "$(which ak)")/_ak-script"
    if [ "$COMP_CWORD" -eq 1 ]; then
       while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$(find "$AK_SUBSCRIPT_DIR"/*.sh -type f -print0 | xargs -0 basename | awk -F "." '{print $1}')" "${COMP_WORDS[$COMP_CWORD]}")
    elif [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=()
        while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$(cat < "$AK_SUBSCRIPT_DIR/${COMP_WORDS[1]}.sh" | grep -E "^function" | awk -F "(" '{print $1}' | cut -c 9- | grep -v "_")" "${COMP_WORDS[$COMP_CWORD]}")
    else
        if type "_${COMP_WORDS[1]}"-completion &>/dev/null; then
            _"${COMP_WORDS[1]}"-completion
        fi
    fi
}

complete -F _ak_completions ak
