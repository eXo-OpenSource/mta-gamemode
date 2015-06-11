#!/bin/bash
cd /home/vrp/MTA_Deployment/servers/5/mods/deathmatch/resources/\[git\]
python3 ./buildscript.py

# Write version label
echo $1 > vrp_build/version.txt
