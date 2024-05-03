#!/bin/bash
set -eu

# Define color variables
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
ENDCOLOR='\033[0m'

# Store the current user
CURRENT_USER="$USER"

if [ $USER != root ]; then
  echo -e $RED"Error: must be root"$ENDCOLOR
  echo -e $YELLOW"Exiting..."$ENDCOLOR
  exit 0
fi

# Check if argument is provided
if [ $# -eq 0 ]; then
  echo -e $RED"Error: Argument missing. Please provide a folder name to install Magic Mirror."$ENDCOLOR
  exit 1
fi
MMPATH="$1"

echo 'Remove screensaver'
apt-get purge xscreensaver*

echo 'Tools'
apt-get install ca-certificates apt-transport-https gnupg curl

# Validation for Chrome installation
read -p "Do you want to install Google Chrome? [Y/n]: " INSTALL_CHROME
INSTALL_CHROME=${INSTALL_CHROME:-Y}  # default is Yes

if [[ $INSTALL_CHROME =~ ^[Yy]$ ]]; then
  echo 'Try to install Chrome'
  if wget -q --spider https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb
    rm -rf google-chrome-stable_current_amd64.deb
    echo -e $GREEN"Error: must be root"$ENDCOLOR
  else
    echo -e "${YELLOW}Google Chrome download failed. Skipping installation.${ENDCOLOR}"
  fi
else
  echo "Skipping Chrome installation."
fi

echo 'Spotify'
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

echo 'Node 20'
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

echo 'Webmin'
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
sh setup-repos.sh
rm -rf setup-repos.sh

apt-get update
apt-get autoremove
apt-get install nodejs webmin spotify-client samba -y

echo 'Magic mirror, switching back to the original user'

# Switch back to the original user
su -c '
cd $HOME
git clone https://github.com/MagicMirrorOrg/MagicMirror $MMPATH
cd $MMPATH
npm run install-mm
chown root $HOME/$MMPATH/node_modules/electron/dist/chrome-sandbox
chmod 4755 $HOME/$MMPATH/node_modules/electron/dist/chrome-sandbox
cp config/config.js.sample config.js
' "$USER"
