CAVERSION='0.19.0'

caversion () {
	echo "Cadrone Aliases Version $CAVERSION"
}

caupdate () {
	# local OLD_VERSION=$CAVERSION
	# wget --no-cache -qO ~/.cadrone_aliases https://gist.github.com/chaos-drone/5b7d8cbe01df6ab64dfce90f32ad3b70/raw/.cadrone_aliases
	# source ~/.cadrone_aliases
	# printf "\n\nAliases updated to version $CAVERSION. Previous version was $OLD_VERSION\n\n"

    # 0.19.0 https://aliases.pavelpetrov.space/cadrone_aliases_0.19.0.tar.gz

    local LATEST_VERSION_DATA="$(wget --no-cache -qO- https://aliases.pavelpetrov.space/latest)"
    local LATEST_VERSION=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f1)

    if [[ $LATEST_VERSION = $CAVERSION ]]; then
        echo "You already have the latest version $LATEST_VERSION."
        return
    fi

    echo "You don't have the latest version."
}