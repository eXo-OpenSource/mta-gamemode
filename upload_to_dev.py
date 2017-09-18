#!/usr/bin/env python3
import os
import tarfile
import requests

ARTIFACTS_PATH = "artifacts.tar.gz"

# Clean previous artifacts
if os.path.isfile(ARTIFACTS_PATH):
	os.remove("artifacts.tar.gz")

# Create tar archive
artifacts = tarfile.open(ARTIFACTS_PATH, "w:gz")

# Add files (see build/make_archives.py)
print("Packing files...")
for name in ["[shader]", "[deps]", "[maps]", "vrp"]:
	if name != "vrp":
		artifacts.add(name)
	else:
		# Rename vrp to vrp_build
		artifacts.add(name, arcname="vrp_build")

artifacts.close()

# Upload artifacts to devserver
print("Uploading files...")
with open(ARTIFACTS_PATH, "rb") as f:
	requests.post("http://mta.exo-reallife.de:5002/upload", files={"file": f}, headers={"API_SECRET": "JeKS8hnQ88ccRKjBvvMHClhzcVHTRu"})

# Delete archive
print("Done! Cleaning up...")
os.remove("artifacts.tar.gz")
