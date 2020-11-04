_shoco_docker_completion_wrapper () {
    if [ 1 -eq $(declare -F _docker_compose >/dev/null ; echo $?) ]; then
        return 1
    fi

    _shoco_completion_wrapper $@
}
