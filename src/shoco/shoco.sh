shoco () (

    local VERSION='0.23.1'

    local LATEST_VERSION_DATA='';

    _shoco_get_latest_version() {
        echo "$(curl -s -H 'Cache-Control: no-cache' ___LATEST_VERSION_DATA_URL___)"
    }

    _shoco_parse_version() {
        if [ -z "$LATEST_VERSION_DATA" ]; then
            LATEST_VERSION_DATA="$(_shoco_get_latest_version)"
        fi

        local OPTIND
        while getopts "suv" OPTION; do
            case "$OPTION" in
                'v') echo "${LATEST_VERSION_DATA}" | cut -d ' ' -f1;;
            esac
        done
    }

	_about() {
		cat <<EOF 
Shoco version $VERSION.
https://aliases.pavelpetrov.space
Licensed under <license> <link to license>

Author: Pavel Petrov (https://pavelpetrov.space)
and contributors (<link to list of contributors>).

Source code: <link to github>
EOF
	}

	_update() {
		local LATEST_VERSION_DATA="$(curl -s -H 'Cache-Control: no-cache' ___LATEST_VERSION_DATA_URL___)"

        if [ 0 -lt "$?" ]; then
            echo "Error: Version check failed."
            return 1
        fi

        local LATEST_VERSION=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f1)

        if [[ $LATEST_VERSION = $VERSION ]]; then
            echo "You already have the latest version $LATEST_VERSION."
            return 0
        fi

        local DOWNLOAD_URL=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f2)
        local DOWNLOAD_PATH="$TMPDIR/$(basename -- $DOWNLOAD_URL)"

        curl -s -H 'Cache-Control: no-cache' $DOWNLOAD_URL --output $DOWNLOAD_PATH

        if [ 0 -lt "$?" ]; then
            echo "Error: Failed to download latest version."
            return 1
        fi

        if [ -f "/opt/shoco/source_shoco.sh" ]; then
            local INSTALLATION_PATH="/opt/shoco"
        elif [ -f "/c/shoco/source_shoco.sh" ]; then
            local INSTALLATION_PATH="/c/shoco"
        else
            echo "Error: Cannot locate installation path."
            return 1
        fi

        (
            cd "$(dirname $DOWNLOAD_PATH)"
            echo "$LATEST_VERSION_DATA" | cut -d ' ' -f3,4 | shasum -a384 --check --status
        )

        if [ 0 -ne "$?" ]; then
            echo "Error: Installation file is corrupted."
            rm $DOWNLOAD_PATH
            return 1
        fi

        tar -x -f $DOWNLOAD_PATH -C $INSTALLATION_PATH

        if [ 0 -lt "$?" ]; then
            echo "Error: Failed to extract latest version from the downloaded file."
            return 1
        fi

        rm -f $DOWNLOAD_PATH

        source "$INSTALLATION_PATH/source_shoco.sh"

        if [ 0 -lt "$?" ]; then
            echo "Error: Failed to load latest version in current shell."
            return 1
        fi

        echo "Congratulations! Shoco updated to the latest version $LATEST_VERSION."
	}

    _help() {
        ABOUT="${1:-shoco}"

        DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
        HELP_ITEM="$DIR/helps/$ABOUT"

        if [ ! -f $HELP_ITEM ]; then
            echo "No help item for $ABOUT"
            return 1
        fi

        CONTENT=$(cat $HELP_ITEM)
        CONTENT_LINES=$(echo "$CONTENT" | wc -l)
        WINDOW_LINES=$(tput lines)

        if [ "$CONTENT_LINES" -gt "$WINDOW_LINES" ]; then
            printf "$CONTENT" | less
        else
            printf "$CONTENT"
        fi
    }

    if [ "-a" = "$1" ]; then
        _about
    elif [ "-h" = "$1" ]; then
        _help "$2"
    elif [ "-v" = "$1" ]; then
        printf "$VERSION"
    elif [ "-u" = "$1" ]; then
        _update
    else
        _help "$2"
    fi
)
