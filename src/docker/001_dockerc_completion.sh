_shoco_docker_completion_wrapper () {
    if [ 1 -eq $(declare -f _docker_compose > /dev/null ; echo $?) ]; then
        return 1
    fi

    local COMPLETION_FUNCTION="$1";
    local ALIAS_NAME="$2";

    eval "
        _$ALIAS_NAME() {
            local PREVIOUS_EXISTING_SETTINGS=\$(shopt -p extglob)
            shopt -s extglob

            _get_comp_words_by_ref -n : cur prev words cword

            declare -F $COMPLETION_FUNCTION >/dev/null && $COMPLETION_FUNCTION

            eval "\$PREVIOUS_EXISTING_SETTINGS"
        }
    "
    complete -F _$ALIAS_NAME $ALIAS_NAME
}
