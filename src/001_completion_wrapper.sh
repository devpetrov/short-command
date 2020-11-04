_shoco_completion_wrapper () {
    if [ 1 -eq $(declare -F _get_comp_words_by_ref >/dev/null ; echo $?) ]; then
        return 1
    fi

    local COMPLETION_FUNCTION="$1"
    local ALIAS_NAME="$2"
    local COMPLETION_WRAPPER="_shoco_${ALIAS_NAME}_complete"

    eval "
        ${COMPLETION_WRAPPER} () {
            _get_comp_words_by_ref -n : cur words cword prev
            declare -F ${COMPLETION_FUNCTION} >/dev/null && ${COMPLETION_FUNCTION}
        }
    "
    complete -F ${COMPLETION_WRAPPER} ${ALIAS_NAME}
}
