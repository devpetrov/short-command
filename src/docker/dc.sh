if [ -z $IS_WINPTY ]; then
    alias dc='docker-compose'
else
    alias dc='winpty docker-compose'
fi
