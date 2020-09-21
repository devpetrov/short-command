CAVERSION='0.20.0'

caversion () {
	echo "Cadrone Aliases Version $CAVERSION"
}

caupdate () {
    local LATEST_VERSION_DATA="$(wget --no-cache -qO- https://aliases.pavelpetrov.space/latest)"

    if [ 0 -lt "$?" ]; then
        echo "Error: Version check failed."
        return 1
    fi

    local LATEST_VERSION=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f1)

    if [[ $LATEST_VERSION = $CAVERSION ]]; then
        echo "You already have the latest version $LATEST_VERSION."
        return 2
    fi

    local DOWNLOAD_URL=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f2)
    local DOWNLOAD_PATH="$TMPDIR/$(basename -- $DOWNLOAD_URL)"

    wget --no-cache -q -O $DOWNLOAD_PATH $DOWNLOAD_URL

    if [ 0 -lt "$?" ]; then
        echo "Error: Failed to download latest version."
        return 1
    fi

    if [ -f "/opt/cadrone_aliases/source_cadrone_aliases.sh" ]; then
        local INSTALLATION_PATH="/opt/cadrone_aliases"
    elif [ -f "/c/cadrone_aliases/source_cadrone_aliases.sh" ]; then
        local INSTALLATION_PATH="/c/cadrone_aliases"
    elif [ -f "$HOME/cadrone_aliases/source_cadrone_aliases.sh" ]; then
        #depricated
        local INSTALLATION_PATH="$HOME/cadrone_aliases"
    else
        echo "Error: Cannot locate isntallation path."
        return 1
    fi

    tar -x -f $DOWNLOAD_PATH -C $INSTALLATION_PATH

    if [ 0 -lt "$?" ]; then
        echo "Error: Failed to extract latest version from the downloaded file."
        return 1
    fi

    rm -f $DOWNLOAD_PATH

    source "$INSTALLATION_PATH/source_cadrone_aliases.sh"

    if [ 0 -lt "$?" ]; then
        echo "Error: Failed to load latest version in current shell."
        return 1
    fi

    echo "Congratulations! You now have the latest version $LATEST_VERSION of Cadrone Aliases installed."
}