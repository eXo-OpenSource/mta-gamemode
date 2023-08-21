#!/bin/bash
CONFIG_DIR=/var/lib/mtasa/mods/deathmatch/resources/vrp_build/server/config

# Exit immediately if something fails
set -e

# If the config does not exist populate it from env variables
if [ ! -f "$CONFIG_DIR/config.ini" ]; then
	echo "Populating config"
	env | while IFS= read -r line; do
		if [[ $line = VRP_* ]]; then
			echo "$line" | sed "s/VRP_//g" >> $CONFIG_DIR/config.ini
		fi
	done
fi

# Start worker server
cd /var/lib/mtasa && exec /var/lib/mtasa/workerserver
