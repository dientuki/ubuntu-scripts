#!/bin/bash

set -eu

# Define color variables
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
ENDCOLOR='\033[0m'

# Define a function to display space change message
display_space_change() {
    local partition=$1
    local initial_space_mb=$2
    local current_space_mb=$3

    local space_change_mb=$((current_space_mb - initial_space_mb))

    if [ $space_change_mb -gt 0 ]; then
        # More space is available, display in green
        echo -e "${GREEN}More space is free on $partition partition: ${space_change_mb} MB${ENDCOLOR}"
    elif [ $space_change_mb -lt 0 ]; then
        # More space is used, display in red
        echo -e "${RED}More space is used on $partition partition: ${space_change_mb} MB${ENDCOLOR}"
    else
        # No change in space, display in yellow
        echo -e "${YELLOW}No change in $partition partition space${ENDCOLOR}"
    fi
}

# Function to remove trash for a given user
remove_trash_for_user() {
    username="$1"
    trash_dir="/home/$username/.local/share/Trash"

    if [ -d "$trash_dir" ]; then
        echo "Removing trash for user $username..."
        rm -rf "$trash_dir"/*
    else
        echo "Trash directory not found for user $username"
    fi
}

if [ $USER != root ]; then
  echo -e $RED"Error: must be root"
  echo -e $YELLOW"Exiting..."$ENDCOLOR
  exit 0
fi

CURKERNEL=$(uname -r 2>/dev/null | sed 's/-*[a-z]//g' | sed 's/-386//g')
if [ -z "$CURKERNEL" ]; then
    echo -e $RED"Failed to determine current kernel version."
    echo -e $YELLOW"Exiting..."$ENDCOLOR
    exit 0
fi

# Run the df command and extract available space in megabytes for /home and / partitions
home_available_mb=$(df --output=avail -BM /home | tail -n 1 | tr -d 'M')
root_available_mb=$(df --output=avail -BM / | tail -n 1 | tr -d 'M')

echo -e $YELLOW"Cleaning apt cache..."$ENDCOLOR
apt-get clean

echo -e $YELLOW"Removing old config files..."$ENDCOLOR
OLDCONF=$(dpkg -l|grep "^rc"|awk '{print $2}')
apt-get purge $OLDCONF -y

echo -e $YELLOW"Removing old kernels..."$ENDCOLOR
LINUXPKG_PATTERN='linux-(image|headers|ubuntu-modules|restricted-modules)'
METALINUXPKG='meta-linux-image'
OLDKERNELS=$(dpkg -l|awk '{print $2}'|grep -E $LINUXPKG_PATTERN |grep -vE $METALINUXPKG|grep -v $CURKERNEL) || true

# Purge old kernels only if OLDKERNELS is not empty
if [ -n "$OLDKERNELS" ]; then
    apt-get purge $OLDKERNELS -y
fi

echo -e $YELLOW"Autoremoving..."$ENDCOLOR
apt-get autoremove -y

echo -e $YELLOW"Emptying every trashes..."$ENDCOLOR
# Remove trash for all regular users
for user in $(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 { print $1 }'); do
    remove_trash_for_user "$user"
done

# Remove trash for the root user
remove_trash_for_user "root"

#Removes old revisions of snaps
#CLOSE ALL SNAPS BEFORE RUNNING THIS
echo -e $YELLOW"Removes old revisions of snaps..."$ENDCOLOR
LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
	while read snapname revision; do
	 snap remove "$snapname" --revision="$revision"
	done
	
home_free_mb=$(df --output=avail -BM /home | tail -n 1 | tr -d 'M')
root_free_mb=$(df --output=avail -BM / | tail -n 1 | tr -d 'M')		

term_width=$(tput cols)	
# Print a blank line
echo	
# Print a line of '=' characters across the terminal width
printf '%*s\n' "$term_width" '' | tr ' ' =
# Call the function to display the message and calculate space_change
display_space_change "/home" "$home_available_mb" "$home_free_mb"
display_space_change "/" "$root_available_mb" "$root_free_mb"	
# Print a line of '=' characters across the terminal width
printf '%*s\n' "$term_width" '' | tr ' ' =
# Print a blank line
echo	

echo -e $GREEN"Script Finished!"$ENDCOLOR
