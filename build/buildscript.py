#!/bin/python3

import os
import io
import xml.etree.ElementTree as ET
import shutil
import subprocess
from subprocess import call
import platform
import time
import sys
import argparse

# Instantiate the parser
parser = argparse.ArgumentParser()
parser.add_argument('--no_files', action='store_true')
parser.add_argument('--branch')
args = parser.parse_args()

start = time.time()
compiler = "tools/luac_mta"
compiler_length = 14
if platform.system() == "Windows":
	compiler = "tools/luac_mta.exe"
	compiler_length = 18
rootdir = "vrp/"
outdir = "vrp_build/"
branch = args.branch
includeFiles = not args.no_files
externalFiles = False
	
# Build vrp_build structure
print("Creating build structure...")

def rm_r(path):
    if os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.exists(path):
        os.remove(path)

rm_r(outdir)
os.mkdir(outdir)
os.mkdir(outdir+"server")
os.mkdir(outdir+"server/http")
os.mkdir(outdir+"server/config")
shutil.copyfile(rootdir+"server/http/api.lua", outdir+"server/http/api.lua")
shutil.copyfile(rootdir+"server/config/config.json.dist", outdir+"server/config/config.json.dist")

# Get files
print("Copying required files...")

files = {}
files["server"] = []
files["client"] = []

tree = ET.parse(rootdir + "meta.xml")
root = tree.getroot()

for child in root.findall("script"):
	if child.attrib["type"] == "server":
		files["server"].append(rootdir+child.attrib["src"])
	if child.attrib["type"] == "client":
		files["client"].append(rootdir+child.attrib["src"])
	if child.attrib["type"] == "shared":
		files["server"].append(rootdir+child.attrib["src"])
		files["client"].append(rootdir+child.attrib["src"])

	root.remove(child)

if externalFiles:
	# Copy maps
	shutil.copytree(rootdir+"files/maps", outdir+"files/maps")

	# Copy only files with <file> tag
	for child in root.findall("file"):
		filename = child.attrib["src"]
		if not os.path.exists(outdir+os.path.dirname(filename)):
			os.makedirs(outdir+os.path.dirname(filename))

		shutil.copyfile(rootdir+filename, outdir+filename)

	# Ignore <vrpfile> tags
	for child in root.findall("vrpfile"):
		root.remove(child)
else:
	if includeFiles:
		# Copy all files
		shutil.copytree(rootdir+"files", outdir+"files")
	else:
		print("Ingoring files.")

serverNode = ET.SubElement(root, "script")
serverNode.set("src", "server.luac")
serverNode.set("type", "server")

clientNode = ET.SubElement(root, "script")
clientNode.set("src", "client.luac")
clientNode.set("type", "client")

tree.write(outdir+"meta.xml")

# We now have all our files in the correct order in 'files'

# Call the compiler
print("Compiling source...")

serverCall = [ compiler, "-o", outdir+"server.luac" ]
serverCall.extend(files["server"])
clientCall = [ compiler ]

if branch != "" and branch != "develop" and branch != "master":
	print("Building release build")
	clientCall.extend([ "-e2", "-s" ])
else:
	print("WARNING: Building debug build")

clientCall.extend([ "-o", outdir+"client.luac" ])
clientCall.extend(files["client"])

process = subprocess.Popen(serverCall, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
output = process.communicate()
output = str(output)
if output[3:(compiler_length+3)] == compiler:
	print("Error:\t" + output[(compiler_length+11):-9])
	sys.exit(1)

process = subprocess.Popen(clientCall, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
output = process.communicate()
output = str(output)
if output[3:(compiler_length+3)] == compiler:
	print("Error:\t" + output[(compiler_length+11):-9])
	sys.exit(1)


print("Done. (took %.2f seconds)" % (time.time() - start))
