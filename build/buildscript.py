#!/bin/python3

import os
import io
import xml.etree.ElementTree as ET
import shutil
from subprocess import call
import platform
import time

start = time.time()
compiler = "tools/luac_mta"
if platform.system() == "Windows":
	compiler = "tools/luac_mta.exe"
rootdir = "vrp/"
outdir = "vrp_build/"

# Build vrp_build structure
print("Creating build structure...")

def rm_r(path):
    if os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.exists(path):
        os.remove(path)

rm_r(outdir)
os.mkdir(outdir)
shutil.copytree(rootdir+"files/maps", outdir+"files/maps")
os.mkdir(outdir+"server")
os.mkdir(outdir+"server/http")
shutil.copyfile(rootdir+"server/http/api.lua", outdir+"server/http/api.lua")

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

for child in root.findall("file"):
	filename = child.attrib["src"]
	if not os.path.exists(outdir+os.path.dirname(filename)):
		os.makedirs(outdir+os.path.dirname(filename))

	shutil.copyfile(rootdir+filename, outdir+filename)

for child in root.findall("vrpfile"):
	root.remove(child)

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

serverCall = [ compiler, "-s", "-e2", "-o", outdir+"server.luac" ]
serverCall.extend(files["server"])
call(serverCall)

clientCall = [ compiler, "-s", "-e2", "-o", outdir+"client.luac" ]
clientCall.extend(files["client"])
call(clientCall)

print("Done. (took %.2f seconds)" % (time.time() - start))
