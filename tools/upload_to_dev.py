#!/usr/bin/env python3
import os
import tarfile
import shutil
import subprocess
import requests
import argparse

# Instantiate the parser
parser = argparse.ArgumentParser()
parser.add_argument('--no_files', action='store_true')
args = parser.parse_args()
includeFiles = not args.no_files

ARTIFACTS_PATH = "artifacts.tar.gz"

# Run linter and buildscript python script
# (script doesnt work, cause of wrong encoding)
#subprocess.call(["C:\\WINDOWS\\system32\\WindowsPowerShell\\v1.0\\powershell.exe", "echo 'GIT_VERSION=\"'$(git rev-parse HEAD)'\"; GIT_BRANCH=\"'$(git rev-parse --abbrev-ref HEAD)'\"' >> vrp/buildinfo.lua"])
os.system("py -3 build/lint.py")
if includeFiles:
	os.system("py -3 build/buildscript.py")
else:
	os.system("py -3 build/buildscript.py --no_files")

# Clean previous artifacts
if os.path.isfile(ARTIFACTS_PATH):
	os.remove("artifacts.tar.gz")

# Create tar archive
artifacts = tarfile.open(ARTIFACTS_PATH, "w:gz")

# Add files (see build/make_archives.py)
print("Packing archive...")
for name in ["[shader]", "[deps]", "[maps]", "vrp_build"]:
	artifacts.add(name)

artifacts.close()

# Upload artifacts to devserver
print("Uploading archive...")
with open(ARTIFACTS_PATH, "rb") as f:
	requests.post("http://mta.exo-reallife.de:5002/upload", files={"file": f}, headers={"API_SECRET": "JeKS8hnQ88ccRKjBvvMHClhzcVHTRu"})

# Delete archive
print("Done! Cleaning up...")
os.remove("artifacts.tar.gz")
shutil.rmtree("vrp_build")