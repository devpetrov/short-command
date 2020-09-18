IS_WINPTY=$(type -t winpty)

if [ -z $IS_WINPTY ]; then
    alias d='docker'
else
    alias d='winpty docker'
fi
