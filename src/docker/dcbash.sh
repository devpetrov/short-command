if [ -z $_SHOCO_IS_WINPTY ]; then
    dcbash() {
        : ${1:?"Provide service name"}
        docker-compose exec $1 bash
    }
else
    dcbash() {
        : ${1:?"Provide service name"}
        winpty docker-compose exec $1 bash
    }
fi

_shoco_docker_completion_wrapper _docker_compose_exec dcbash

# --register-name dcbash