#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo "E: Please run this script as root."
  exit 1
fi
mkdir -pv /opt/pluginmanager/tmp /opt/pluginmanager/config /opt/pluginmanager/downloads /opt/pluginmanager/logs
read -p " -> Please enter your server version: " sver
echo $sver
echo $sver > /opt/pluginmanager/config/server-version.txt
echo " -> Downloading colours configuration..."
wget -q -O /opt/pluginmanager/config/colours.conf https://raw.githubusercontent.com/thedistromaker/serverplugins/setuptools/colours.conf
echo " -> Downloading version configuration..."
wget -q -O /opt/pluginmanager/config/version.txt https://raw.githubusercontent.com/thedistromaker/serverplugins/main/version.txt
echo " -> Downloading and setting up script..."
wget -q -O /usr/bin/pluginmgr https://raw.githubusercontent.com/thedistromaker/serverplugins/setuptools/script.sh
chmod +x /usr/bin/pluginmgr
touch /opt/pluginmanager/config/targetdir.conf
echo " -> Done!"
exit 0
