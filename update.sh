#!/bin/bash

set -eu

# Define color variables
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
ENDCOLOR='\033[0m'
term_width=$(tput cols)

if [ $USER != root ]; then
  echo -e $RED"Error: must be root"
  echo -e $YELLOW"Exiting..."$ENDCOLOR
  exit 0
fi

# Update snap packages
echo -e "${YELLOW}Updating snap packages...${ENDCOLOR}"
snap_output=$(sudo snap refresh 2>&1)
echo -e "${snap_output}"

# Update apt-get packages
echo -e "${YELLOW}Updating apt-get packages...${ENDCOLOR}"
apt-get update
sudo apt-get upgrade -y

# Check if updates were made for snap packages
if [[ "$snap_output" != *"All snaps are up to date."* ]]; then
    echo -e "${GREEN}Snap updates were made.${ENDCOLOR}"
else
    echo -e "${YELLOW}No snap updates were made.${ENDCOLOR}"
fi

echo -e $GREEN"Script Finished!"$ENDCOLOR
