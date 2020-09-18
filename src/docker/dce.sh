IS_WINPTY=$(type -t winpty)

if [ -z $IS_WINPTY ]; then
    alias dce='docker-compose exec'
else
    alias dce='winpty docker-compose exec'
fi
