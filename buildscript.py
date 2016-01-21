#!/bin/python
import os
import io
import xml.etree.ElementTree as ET
import shutil
from subprocess import call
import platform

compiler = "tools/luac_mta"
if platform.system() == "Windows":
	compiler = "tools/luac_mta.exe"
rootdir = "vrp/"
outdir = "vrp_build/"

# At first remove UTF8BOM
if platform.system() == "Windows":
	os.chdir("tools")
	call(["py", "-3", "removeUTF8BOM.py" ])
	os.chdir("..")

# Build vrp_build structure
def rm_r(path):
    if os.path.isdir(path):
        shutil.rmtree(path)
    elif os.path.exists(path):
        os.remove(path)
rm_r(outdir)
os.mkdir(outdir)
shutil.copytree(rootdir+"files", outdir+"files")
shutil.copyfile(rootdir+"whitelist.xml", outdir+"whitelist.xml")
os.mkdir(outdir+"server")
os.mkdir(outdir+"server/http")
shutil.copyfile(rootdir+"server/http/api.lua", outdir+"server/http/api.lua")

# Get files
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

serverNode = ET.SubElement(root, "script")
serverNode.set("src", "server.luac")
serverNode.set("type", "server")

clientNode = ET.SubElement(root, "script")
clientNode.set("src", "client.luac")
clientNode.set("type", "client")


tree.write(outdir+"meta.xml")

# We now have all our files in the correct order in 'files'

# Call the compiler
serverCall = [ compiler, "-o", outdir+"server.luac" ]
serverCall.extend(files["server"])
call(serverCall)

clientCall = [ compiler, "-o", outdir+"client.luac" ]
clientCall.extend(files["client"])
call(clientCall)