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

cd $HOME

echo 'Remove screensaver'
apt-get purge xscreensaver*

echo 'Tools'
apt-get install ca-certificates apt-transport-https gnupg curl

echo 'Chrome'
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
rm -rf google-chrome-stable_current_amd64.deb

echo 'Spotify'
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

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

echo 'Magic mirror'
git clone https://github.com/MagicMirrorOrg/MagicMirror camouflage
cd camouflage
npm run install-mm

chown root $HOME/camouflage/node_modules/electron/dist/chrome-sandbox
chmod 4755 $HOME/camouflage/node_modules/electron/dist/chrome-sandbox
