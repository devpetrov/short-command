#!/bin/bash

#todo: add variable not to load shoco with 001 precedence over compl. wrapper

#
#  Installator for Shoco (Short Command)
#  Copyright (C) 2020  Pavel Petrov
#  
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#  
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

shoco_install ()
{
    if [[ 0 -eq $(declare -f shoco > /dev/null; echo $? ) ]]; then
        shoco -u
        return
    fi

    local BASE_URL='https://getshoco.org'

    local LATEST_VERSION_DATA="$(curl -s -H 'Cache-Control: no-cache' $BASE_URL/latest)"

    if [ 0 -ne "$?" ]; then
        _shoco_install_error 100; return $?
    fi

    local LATEST_VERSION=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f1)

    local DOWNLOAD_DIR="$TMPDIR"

    local DOWNLOAD_URL=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f2)
    local DOWNLOAD_PATH="$DOWNLOAD_DIR/$(basename $DOWNLOAD_URL)"

    curl -s $DOWNLOAD_URL --output "$DOWNLOAD_PATH"

    if [ 0 -ne "$?" ]; then
        _shoco_install_error 101; return $?
    fi

    if [[ -z "$(cygcheck --version)" ]]; then
        local INSTALLATION_DIR='/opt/shoco'
    else
        local INSTALLATION_DIR='/c/shoco'
    fi

    if [[ ! -d $INSTALLATION_DIR ]]; then
        mkdir -p $INSTALLATION_DIR

        if [ 0 -ne "$?" ]; then
            _shoco_install_error 102 "$DOWNLOAD_PATH" "$INSTALLATION_DIR"; return $?
        fi
    fi

    tar -xf $DOWNLOAD_PATH -C $INSTALLATION_DIR

    if [ 0 -ne "$?" ]; then
        _shoco_install_error 103  "$DOWNLOAD_PATH" "$INSTALLATION_DIR"; return $?
    fi

    rm $DOWNLOAD_PATH

    if [ 0 -ne "$?" ]; then
        echo "Notice: failed to delete downloaded files."
        echo "Try to remove them manually: $DOWNLOAD_PATH"
    fi

    local BASHRC_LINE=". $INSTALLATION_DIR/source_shoco.sh"
    local IN_BASHRC=$(grep -e 'source_shoco.sh' $HOME/.bashrc)

    local HAS_ERRORS=0
    if [ -z "$IN_BASHRC" ]; then
        printf "\n$BASHRC_LINE\n" >> $HOME/.bashrc
        if [ 0 -ne "$?" ]; then
            HAS_ERRORS=1
            echo "Warning: failed to write to .bashrc file."
            printf "Please add the following in your $HOME/.bashrc file:\n$BASHRC_LINE\n"
        fi
    else
        sed -i "s;^[^#].*source_shoco\.sh;$BASHRC_LINE;" $HOME/.bashrc
        if [ 0 -ne "$?" ]; then
            HAS_ERRORS=1
            echo "Warning: failed to write to .bashrc file."
            printf "Please add the following in your $HOME/.bashrc file:\n$BASHRC_LINE\n"
        fi
    fi

    eval $BASHRC_LINE

    if [ 0 -ne "$?" ]; then
        HAS_ERRORS=1
        echo "Warning: failed to load Shoco."
        echo "Try executing: ${BASHRC_LINE}"
    fi

    if [ 0 -eq "$HAS_ERRORS" ]; then
        printf "Installation was successfull.\nThank you for installing Shoco!\nType shoco --help for more information.\n"
    else
        printf "Thank you for choosing Shoco!\nInstallation passed with some errors.\nFollowing the hints will resolve them, hopefully.\n"
        return 3
    fi
}

_shoco_install_error ()
{
    local DOWNLOAD_PATH="$2"
    local INSTALLATION_DIR="$3"

    case "$1" in
        100) echo "Error: failed to retreive available versions.";;
        101) echo "Error: failed to download Shoco.";;
        102) echo "Error: failed to create installation directory.";;
        103) echo "Error: failed to decompress installation files.";;
    esac

    # Error codes up to 99 are not handled
    if [ 101 -lt "$1" ]; then
        echo "Deleting downloaded files."
        if [ -n "$DOWNLOAD_PATH" ]; then
            rm "$DOWNLOAD_PATH"
            if [ 0 -ne "$?" ]; then
                echo "Error: failed to delete download file: $DOWNLOAD_PATH"
            fi
        fi
    fi

    if [ 102 -lt "$1" ]; then
        echo "Deleting the directory created for installation."
        if [ -n "$INSTALLATION_DIR" ]; then
            rm "$INSTALLATION_DIR"
            if [ 0 -ne "$?" ]; then
                echo "Error: failed to delete installation directory $INSTALLATION_DIR"
            fi
        fi
    fi
    
    echo "Installation failed."
    return $1
}

shoco_install
SHOCO_INSTALL_RESULT=$?
unset -f shoco_install _shoco_install_error

return $SHOCO_INSTALL_RESULT
