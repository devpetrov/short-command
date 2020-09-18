cahelp() {
    ABOUT="${1:-cahelp}"

    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    HELP_ITEM="$DIR/helps/$ABOUT"

    if [ ! -f $HELP_ITEM ]; then
        echo "No help item for $ABOUT"
        return 1
    fi

    # B_=$(tput bold)
    # _B=$(tput sgr0)

    CONTENT=$(cat $HELP_ITEM | sed 's/^/    /')
    CONTENT_LINES=$(echo "$CONTENT" | wc -l)
    WINDOW_LINES=$(tput lines)

    if [ "$CONTENT_LINES" -gt "$WINDOW_LINES" ]; then
        printf "$CONTENT" | less
    else
        printf "$CONTENT"
    fi
}
