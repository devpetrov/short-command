if [ -z $IS_WINPTY ]; then
    alias d='docker'
else
    alias d='winpty docker'
fi
