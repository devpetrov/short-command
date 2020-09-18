IS_WINPTY=$(type -t winpty)

if [ -z $IS_WINPTY ]; then
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
