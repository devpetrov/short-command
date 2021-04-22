if [ -z $_SHOCO_IS_WINPTY ]; then
    alias dcr='docker-compose run'
else
    alias dcr='winpty docker-compose run'
fi

_shoco_docker_completion_wrapper _docker_compose_run dcr

# --register-name dcr