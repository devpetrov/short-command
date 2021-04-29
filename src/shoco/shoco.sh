shoco () {

    local VERSION='___VERSION___'

    local LATEST_VERSION_DATA='';

    _shoco_get_latest_version() {
        LATEST_VERSION_DATA="$(curl -s --fail -H 'Cache-Control: no-cache' ___LATEST_VERSION_DATA_URL___)"

        if [ 0 -lt "$?" ]; then
            echo "Error: Version check failed."
            return 1
        fi
    }

    _shoco_parse_version() {
        if [ -z "$LATEST_VERSION_DATA" ]; then
            _shoco_get_latest_version || return 1
        fi

        local OPTIND
        while getopts "suv" OPTION; do
            case "$OPTION" in
                v) echo "${LATEST_VERSION_DATA}" | cut -d ' ' -f1;;
                u) echo "${LATEST_VERSION_DATA}" | cut -d ' ' -f2;;
                s) echo "${LATEST_VERSION_DATA}" | cut -d ' ' -f3,4;;
            esac
        done
    }

	_shoco_about() {
        local VERSION_LINE="Version: ${VERSION}."

        local LATEST_VERSION
        LATEST_VERSION="$(_shoco_parse_version -v)"

        if [ 0 -eq "$?" ]; then 
            if [[ $LATEST_VERSION != $VERSION ]]; then
                VERSION_LINE+="\n! New version ${LATEST_VERSION} is available. Use shoco -u to update. !"
            else
                VERSION_LINE+="\nYou are running the latest version of Shoco."
            fi
        else
            VERSION_LINE+="\n[Cannot retrieve update information. Try again later.]"
        fi

		printf "Shoco (Short Command)

$VERSION_LINE

https://getshoco.org
Released under MIT License. Type shoco -h license for more information.

Author: Pavel Petrov (https://pavelpetrov.space)

Source code available at: https://github.com/devpetrov/short-command"
	}

	_shoco_update() {
        _shoco_get_latest_version || return 1

        local LATEST_VERSION=$(_shoco_parse_version -v)

        # if [[ $LATEST_VERSION = $VERSION ]]; then
        #     echo "You already have the latest version $LATEST_VERSION."
        #     return 0
        # fi

        echo "New version ${LATEST_VERSION} is available. Processing.."

        # Determinate writeable download directory.
        local DOWNLOAD_DIR="${TMPDIR:-/tmp}"

        while [ ! -w "$DOWNLOAD_DIR" ]; do
            printf "\nDirectory $DOWNLOAD_DIR is not writeable or does not exists.\n"
            printf "Please, provide writable directory to download temporary files: "
            read DOWNLOAD_DIR
        done

        local DOWNLOAD_URL=$(_shoco_parse_version -u)
        local DOWNLOAD_PATH="$DOWNLOAD_DIR/$(basename -- $DOWNLOAD_URL)"

        curl -s -H 'Cache-Control: no-cache' $DOWNLOAD_URL --output $DOWNLOAD_PATH

        if [ 0 -lt "$?" ]; then
            echo "Error: Failed to download latest version."
            return 1
        fi

        if [ -z "$SHOCO_INSTALLATION_DIR" ]; then
            echo "Error: Cannot locate installation path. You can set the installation path by running:"
            echo "export SHOCO_INSTALLATION_DIR=/path/to/where/source_shoco.sh/is/located"
            return 1
        fi

        (
            cd "$(dirname $DOWNLOAD_PATH)"
            _shoco_parse_version -s | shasum -a384 --check --status
        )

        if [ 0 -ne "$?" ]; then
            echo "Error: Installation file is corrupted."
            rm "$DOWNLOAD_PATH"
            return 1
        fi

        local LATEST_VERSION_DIR="$SHOCO_INSTALLATION_DIR/$LATEST_VERSION"

        tar -x -f "$DOWNLOAD_PATH" -C "$SHOCO_INSTALLATION_DIR"

        if [ 0 -lt "$?" ]; then
            echo "Error: Failed to extract latest version from the downloaded file."
            return 1
        fi

        rm -f "$DOWNLOAD_PATH"

        local SOURCE_FILE_PATH="$SHOCO_INSTALLATION_DIR/source_shoco.sh"

        cat << SOURCEFILE > "$SOURCE_FILE_PATH"
export SHOCO_INSTALLATION_DIR="$SHOCO_INSTALLATION_DIR"
. $LATEST_VERSION_DIR/shoco.sh
SOURCEFILE

        . "$SOURCE_FILE_PATH"

        if [ 0 -lt "$?" ]; then
            echo "Error: Failed to load latest version in current shell."
            return 1
        fi

        echo "Congratulations! Shoco updated to the latest version $LATEST_VERSION."
	}

    _shoco_help() {
        ABOUT=$(echo "${1:-shoco}" | tr "~" "_")

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
        _shoco_about
    elif [ "-h" = "$1" ]; then
        _shoco_help "$2"
    elif [ "-v" = "$1" ]; then
        printf "$VERSION"
    elif [ "-u" = "$1" ]; then
        _shoco_update
    else
        _shoco_help "$2"
    fi
}
