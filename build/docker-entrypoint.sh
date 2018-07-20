#!/bin/sh
CONFIG_DIR=/var/lib/mtasa/mods/deathmatch/resources/vrp_build/server/config

# Exit immediately if something fails
set -e

# Create config if not exists
echo "Checking config file integrity"
if [ ! -f "$CONFIG_DIR/config.json" ]; then
	echo "Copying default config"
	cp /var/lib/mtasa/config.json.dist "$CONFIG_DIR/"
	cp /var/lib/mtasa/config.json.dist "$CONFIG_DIR/config.json"
fi

# Start worker server
cd /var/lib/mtasa && exec /var/lib/mtasa/workerserver
