#!/bin/bash

#
#  Installer for Shoco (Short Command)
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
#  Source code is at https://github.com/devpetrov/short-command/blob/master/installer.sh
#

shoco_install ()
{
    # If Shoco is already installed then just update
    if [[ 0 -eq $(declare -f shoco > /dev/null; echo $? ) ]]; then
        shoco -u
        return
    fi

    # Determinate writeable installation path based on OS
    if [ -n "$(type cygcheck 2> /dev/null)" ]; then
        # cygcheck is present OS is Windows
        local INSTALLATION_DIR='/c/shoco'
    else
        # No cygcheck present OS is *nix
        local INSTALLATION_DIR="$HOME/shoco"
    fi

    # Before continue, check if the installation directory is writable
    local INSTALLATION_DIR_PARENT="$(dirname "$INSTALLATION_DIR")"
    if [ ! -w "$INSTALLATION_DIR_PARENT" ]; then
        printf "Shoco installer wants to install Shoco in $INSTALLATION_DIR_PARENT directory which is not writeable.\n"
        printf "Make the directory writeable and run the installer again.\n"
        _shoco_install_error 95; return $?
    fi

    local BASE_URL='https://getshoco.org'

    # Retrieve data for the latest version
    printf "Retrieving information for latest versions...\n"
    local LATEST_VERSION_DATA
    LATEST_VERSION_DATA="$(curl --silent --fail -H 'Cache-Control: no-cache' "$BASE_URL/latest")"

    # Failed to retrieve data? Print message end stop script
    if [ 0 -ne $? ]; then
        _shoco_install_error 100; return $?
    fi

    # Extract version number and download url from retrieved data
    local LATEST_VERSION=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f1)
    local DOWNLOAD_URL=$(echo $LATEST_VERSION_DATA | cut -d ' ' -f2)

    # Determinate writeable download directory.
    local DOWNLOAD_DIR="${TMPDIR:-/tmp}"

    while [ ! -w "$DOWNLOAD_DIR" ]; do
        printf "\nDirectory $DOWNLOAD_DIR is not writeable or does not exists.\n"
        printf "Please, provide writable directory to download temporary files: "
        read DOWNLOAD_DIR
    done

    # Determinate path with filename of the downloaded file.
    local DOWNLOAD_PATH="$DOWNLOAD_DIR/$(basename $DOWNLOAD_URL)"

    # Download installation files
    printf "Downloading installation files to: $DOWNLOAD_PATH\n"
    curl -s $DOWNLOAD_URL --output "$DOWNLOAD_PATH"

    # Failed to download files? Print message, rollback and stop script
    if [ 0 -ne "$?" ]; then
        _shoco_install_error 101; return $?
    fi

    # Create installation directory or print message, rollback and stop script on fail.
    if [[ ! -d $INSTALLATION_DIR ]]; then
        mkdir -p $INSTALLATION_DIR

        if [ 0 -ne "$?" ]; then
            _shoco_install_error 102 "$DOWNLOAD_PATH" "$INSTALLATION_DIR"; return $?
        fi
    fi

    # Extract files from downloaded archive
    printf "Extracting files and installing Shoco in $INSTALLATION_DIR ...\n"
    tar -xf $DOWNLOAD_PATH -C $INSTALLATION_DIR

    # Fail to extract?
    if [ 0 -ne "$?" ]; then
        _shoco_install_error 103  "$DOWNLOAD_PATH" "$INSTALLATION_DIR"; return $?
    fi

    # Create explicit file that sources Shoco and provides environment variable
    # keeping installation path for versions.
    local SOURCE_FILE_PATH="$INSTALLATION_DIR/source_shoco.sh"

    if [ ! -f "$SOURCE_FILE_PATH" ]; then
        touch "$SOURCE_FILE_PATH"

        if [ 0 -ne "$?" ]; then
            _shoco_install_error 104 "$DOWNLOAD_PATH" "$INSTALLATION_DIR"; return $?
        fi
    fi

    cat << SOURCEFILE > "$SOURCE_FILE_PATH"
export SHOCO_INSTALLATION_DIR="$INSTALLATION_DIR"
. $INSTALLATION_DIR/$LATEST_VERSION/shoco.sh
SOURCEFILE

    # Files are extracted. Remove downloaded file it is not needed anymore.
    printf "Deleting temporary files...\n"
    rm $DOWNLOAD_PATH

    # Failed to remove downloaded file? It is not critical, just display notice.
    if [ 0 -ne "$?" ]; then
        echo "Notice: failed to delete downloaded files."
        echo "Try to remove them manually: $DOWNLOAD_PATH"
    fi

    # Files are downloaded and placed in the installation directory.
    # Add sourcing line to ~/.bashrc file to enable Shoco for shell sessions.
    local SHELL_SOURCE_LINE=". $SOURCE_FILE_PATH"

    local BASHRC_FILE="$HOME/.bashrc"

    # In some cases ~/.bashrc file may not exist
    if [ ! -f "$BASHRC_FILE" ]; then
        printf "Creating $BASHRC_FILE file..."
        touch "$BASHRC_FILE"
    fi

    # Rise flag in case the script failed to write in .bashrc file or
    # failed to source Shoco for current shell session. The flag is used to
    # determine the message at the end of the installation.
    local HAS_ERRORS=0

    # Add line in .bashrc to source Shoco for each shell session.
    # 
    # Check if such line exists and is not commented.
    if [ -z "$(grep -e '^[^#].*source_shoco.sh' $HOME/.bashrc)" ]; then
    
        # No line is found in .bashrc that sources Shoco. Append it.

        printf "Appending Shoco source line to your .bashrc file.\n"
        printf "\n$SHELL_SOURCE_LINE\n" >> $HOME/.bashrc
        if [ 0 -ne "$?" ]; then
            HAS_ERRORS=1
            printf "Warning: failed to write to .bashrc file.\n"
            printf "Please add the following in $BASHRC_FILE file:\n$SHELL_SOURCE_LINE\n"
        fi
    fi

    # Source Shoco to be ready for use right after installation
    printf "Sourcing Shoco for current shell session.\n"
    $SHELL_SOURCE_LINE

    # Failed to source?
    if [ 0 -ne "$?" ]; then
        HAS_ERRORS=1
        echo "Warning: failed to source Shoco."
        echo "Try executing: ${SHELL_SOURCE_LINE}"
    fi

    # Print final status message
    if [ 0 -eq "$HAS_ERRORS" ]; then
        # Success message
        printf "\n\nInstallation was successful.\nThank you for installing Shoco!\nType shoco --help for more information.\n\n"
    else
        # Installation passed but with some errors
        printf "\n\nThank you for choosing Shoco!\nInstallation passed with some errors.\nFollowing the hints will resolve them, hopefully.\n\n"
        return 3
    fi
}

_shoco_install_error ()
{
    # Name arguments
    local DOWNLOAD_PATH="$2"
    local INSTALLATION_DIR="$3"

    # Print message based on error code from the installer
    case "$1" in
        100) echo "Error: failed to retrieve version information.";;
        101) echo "Error: failed to download Shoco.";;
        102) echo "Error: failed to create installation directory.";;
        103) echo "Error: failed to decompress installation files.";;
        104) echo "Error: failed to create sourcing file.";;
    esac

    # Handle errors. Error codes up to 99 are not handled.
    # Think for the error codes as installation step number. If you fail on step X
    # rollback all the steps before it too.

    # Run on error codes greater than 101
    if [ 101 -lt "$1" ]; then
        echo "Deleting downloaded files."
        if [ -n "$DOWNLOAD_PATH" ]; then
            rm "$DOWNLOAD_PATH"
            if [ 0 -ne "$?" ]; then
                echo "Error: failed to delete download file: $DOWNLOAD_PATH"
            fi
        fi
    fi

    # Run on error codes greater than 102
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
