if [ -z $_SHOCO_IS_WINPTY ]; then
    alias dce='docker-compose exec'
else
    alias dce='winpty docker-compose exec'
fi
