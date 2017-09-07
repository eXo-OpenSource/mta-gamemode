#!/usr/bin/env python3
import os
import tarfile
import shutil
import requests

ARTIFACTS_PATH = "artifacts.tar.gz"

# Run linter and buildscript python script
os.system("py -3 build/lint.py")
os.system("py -3 build/buildscript.py")

# Clean previous artifacts
if os.path.isfile(ARTIFACTS_PATH):
	os.remove("artifacts.tar.gz")

# Create tar archive
artifacts = tarfile.open(ARTIFACTS_PATH, "w:gz")

# Add files (see build/make_archives.py)
print("Packing files...")
for name in ["[shader]", "[deps]", "[maps]", "vrp_build"]:
	artifacts.add(name)

artifacts.close()

# Upload artifacts to devserver
print("Uploading files...")
with open(ARTIFACTS_PATH, "rb") as f:
	requests.post("http://mta.exo-reallife.de:5002/upload", files={"file": f}, headers={"API_SECRET": "JeKS8hnQ88ccRKjBvvMHClhzcVHTRu"})

# Delete archive
print("Done! Cleaning up...")
os.remove("artifacts.tar.gz")
shutil.rmtree("vrp_build")
