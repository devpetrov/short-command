IS_WINPTY=$(type -t winpty)

if [ -z $IS_WINPTY ]; then
    alias dcr='docker-compose run'
else
    alias dcr='winpty docker-compose run'
fi
